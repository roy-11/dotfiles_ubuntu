#!/usr/bin/env bash
# 秘密情報の Bash 経由読込と .git/hooks/ 改ざんをブロックする PreToolUse hook
#
# 配置先: ~/.claude/hooks/secret-guard.sh
# 登録方法: settings.json の hooks.PreToolUse に matcher "Bash" として登録
#
# 設計方針:
#   - permissions.deny の Read(...) / Write(...) / Edit(...) パターンと整合させる
#   - Read/Write/Edit ツール経由で禁止しているものは Bash 経由でも禁止する
#   - permissions.deny に項目を追加した場合は、本スクリプトのパターンにも追加する
#   - パターン照合は bash 組み込み [[ =~ ]] を使い、grep の fork を避ける（高速化）
#     → JSON 解析の jq 1 回以外は外部プロセスを起動しない
#
# 防げるもの:
#   1. .git/hooks/ への書き込み（永続バックドアの仕込み）
#   2. core.hooksPath の改変（hooks ディレクトリのリダイレクト攻撃）
#   3. Read/Write/Edit deny に列挙された秘密情報ファイル/ディレクトリへの Bash 経由アクセス

set -euo pipefail

INPUT=$(cat)

# jq 未導入時は検査をスキップして通過させる
# （set -euo pipefail 下で jq が無いと非ゼロ終了し、全 Bash コマンドが
#   意図せずブロックされるのを防ぐ）
if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# jq のパースエラー（malformed JSON / 想定外スキーマ）時も fail-open で通過させる。
# set -euo pipefail 下で jq が非ゼロ終了するとスクリプト全体が exit 1 になり、
# Claude Code が「エラー（BLOCK ではない）」扱いにする恐れがあるため、明示的に exit 0 へ倒す。
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[[ -z "$CMD" ]] && exit 0

block() {
  # PreToolUse hook の正規プロトコル:
  #   - stderr に reason を書き込み、Claude へのフィードバックとして渡す
  #   - exit 2 でアクションを BLOCK
  #   - exit 0 は「objection なし=実行許可」なので、ブロックには使えない
  # 公式 docs: https://code.claude.com/docs/en/hooks
  echo "$1" >&2
  exit 2
}

# 末尾区切り文字（ファイル名引数の終端）の共通部品
# 空白 / 行末 / 引用符 / 各種シェル記号
END='([[:space:]]|$|"|'"'"'|;|\||&|`|>|<|\))'
# 先頭区切り文字（行頭 or 区切り文字）
BEG='(^|[[:space:]/=@"'"'"'(])'

# === ガード1: .git/hooks/ への操作をブロック ===
# 補足:
#   Claude Code は .git, .claude, .husky 等の特殊フォルダへの操作には標準で確認を入れます。
#   ただし .git/hooks/ は「commit/push 時に自動実行される永続バックドアを仕込める」という
#   特に危険な経路のため、確認を介さず一律 BLOCK する方針です。
#   .claude や .husky は通常運用で編集する可能性があるためここでは BLOCK しません
#   （Claude Code 標準の確認に任せます）。
re='(\.git/hooks/|\.githooks/|core\.hooksPath)'
[[ "$CMD" =~ $re ]] && block ".git/hooks/ への操作は禁止されています（永続バックドア対策）。必要な場合はターミナルで直接操作してください。"

# === ガード2: permissions.deny に列挙された秘密情報パターン ===
# permissions.deny の Read(...) / Write(...) / Edit(...) と1対1で対応。
# permission を追加・変更したら本リストも更新すること。

# Read/Write/Edit(.env), (./.env), (.env.*), (**/.env), (**/.env.*), (**/.env-*), (**/.env_*)
#   → .env を単独のファイル名として参照しているパターン（区切りは . _ - に対応）
re="${BEG}\\.env([[:space:]]|\$|\"|'|;|\\||&|\`|>|<|\\)|[._-][a-zA-Z0-9])"
[[ "$CMD" =~ $re ]] && block "秘密情報ファイル（.env 系）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/*.pem), (**/*.key), (**/*.p12), (**/*.pfx), (**/*.keystore)
re="\\.(pem|key|p12|pfx|keystore)${END}"
[[ "$CMD" =~ $re ]] && block "秘密鍵/証明書ファイル（*.pem, *.key, *.p12, *.pfx, *.keystore）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/.ssh/**), (**/.aws/**), (**/.kube/**), (**/.gnupg/**), (**/.azure/**), (**/.vercel/**)
#   → 認証情報ディレクトリへのあらゆるアクセス
re="${BEG}\\.(ssh|aws|kube|gnupg|azure|vercel)/"
[[ "$CMD" =~ $re ]] && block "認証情報ディレクトリ（.ssh, .aws, .kube, .gnupg, .azure, .vercel）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/.config/gcloud/**)
re='\.config/gcloud/'
[[ "$CMD" =~ $re ]] && block "GCP 認証情報（.config/gcloud/）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/.docker/**), (**/.terraformrc), (**/.terraform.d/**), (**/.git-credentials)
re="${BEG}(\\.docker/|\\.terraformrc${END}|\\.terraform\\.d/|\\.git-credentials${END})"
[[ "$CMD" =~ $re ]] && block "認証情報（.docker, .terraformrc, .terraform.d, .git-credentials）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/.netrc), (**/.npmrc), (**/.pypirc)
#   → 相対パス（`cat .netrc` 等）でもバイパスされないよう BEG アンカーを使用
re="${BEG}\\.(netrc|npmrc|pypirc)${END}"
[[ "$CMD" =~ $re ]] && block "認証用 dotfile（.netrc, .npmrc, .pypirc）への Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/.bash_history), (**/.zsh_history), (**/.fish_history)
#   → シェル履歴（誤って入力した秘密情報が残っている可能性）
re="${BEG}\\.(bash|zsh|fish)_history${END}"
[[ "$CMD" =~ $re ]] && block "シェル履歴ファイルへの Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/id_rsa*), (**/id_dsa*), (**/id_ed25519*), (**/id_ecdsa*)
#   → SSH 秘密鍵のファイル名パターン（.ssh ディレクトリ外でも捕捉）
re="${BEG}id_(rsa|dsa|ed25519|ecdsa)([_.[:space:]]|\$|\"|'|;|\\||&|\`|>|<|\\))"
[[ "$CMD" =~ $re ]] && block "SSH 秘密鍵パターンのファイル（id_rsa, id_ed25519 等）への Bash 経由アクセスはブロックされました。"

# token / secret は大文字小文字を区別せず判定（grep -i 相当）
shopt -s nocasematch

# Read/Write/Edit(**/*token*.{json,yaml,yml,env,toml,conf,properties,txt}) + (**/.*token*)
#   → ファイル名に token を含むものへのアクセス（拡張子付き or ドット始まり）
re="${BEG}(\\.[a-zA-Z0-9._-]*token[a-zA-Z0-9._-]*|[a-zA-Z0-9._-]*token[a-zA-Z0-9._-]*\\.(json|ya?ml|toml|env|conf|properties|txt|secret))${END}"
[[ "$CMD" =~ $re ]] && block "token を含むファイルへの Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/*secret*.{json,yaml,...}) + (**/.*secret*)
re="${BEG}(\\.[a-zA-Z0-9._-]*secret[a-zA-Z0-9._-]*|[a-zA-Z0-9._-]*secret[a-zA-Z0-9._-]*\\.(json|ya?ml|toml|env|conf|properties|txt))${END}"
[[ "$CMD" =~ $re ]] && block "secret を含むファイルへの Bash 経由アクセスはブロックされました。"

shopt -u nocasematch

# Read/Write/Edit(**/credentials.{json,yaml,yml,env,toml,conf,tfrc}) + (**/.credentials*) + (**/application_default_credentials.json)
#   broad prefix ([^space"']*) で application_default_credentials.json や
#   my_app_credentials.json のような派生名もカバー
re="${BEG}(\\.credentials[a-zA-Z0-9._-]*|[^[:space:]\"']*credentials\\.(json|yaml|yml|env|toml|conf|tfrc))${END}"
[[ "$CMD" =~ $re ]] && block "credentials ファイルへの Bash 経由アクセスはブロックされました。"

# Read/Write/Edit(**/secrets.{json,yaml,yml,env,toml,conf}) + (**/.secrets*)
re="${BEG}(\\.secrets[a-zA-Z0-9._-]*|secrets\\.(json|yaml|yml|env|toml|conf))${END}"
[[ "$CMD" =~ $re ]] && block "secrets ファイルへの Bash 経由アクセスはブロックされました。"

exit 0
