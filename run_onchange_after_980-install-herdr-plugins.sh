#!/usr/bin/env bash
set -euo pipefail

# herdr / bun / cargo など mise 管理のツールを使うため（初回 bootstrap 時はシェル設定が未読込）
export PATH="$HOME/.local/share/mise/shims:$PATH"

command -v herdr >/dev/null 2>&1 || {
  echo "herdr is not installed"
  exit 1
}

# plugins

# vim-navigator: Neovim と herdr のペイン間を Ctrl+h/j/k/l でシームレスに移動
herdr plugin install \
  bojackduy/nvim-herdr-navigation/herdr-vim-navigator \
  --yes

# terminal-browser: ターミナル内で動く実ブラウザ
# Web UI の確認やエージェントからの操作に使う
herdr plugin install \
  zenbu-labs/terminal-browser/herdr-plugin \
  --yes

# herdr-radar: サイドバーの Agents 一覧を、作業中・返信待ち・放置中などが一目でわかるパネルにする
# ※初回起動時に herdr/config.toml と kitty.conf に設定を書き込む
herdr plugin install \
  hhdebb/herdr-radar \
  --yes

# herdr-navigator: ワークスペース・エージェント・プロジェクト・アクションなどへファジー検索でジャンプ
herdr plugin install \
  thanhdat77/herdr-navigator \
  --yes

# herdr-plugin-manager: ポップアップでプラグインのインストール・更新・有効/無効化やマーケットプレイス閲覧
herdr plugin install \
  speardragon/herdr-plugin-manager \
  --yes

# herdr-web-ui: ブラウザやスマホから各エージェントのペインをチャットとターミナルで操作
# ※ビルドと起動に bun が必要（mise でインストール）
herdr plugin install \
  devswha/herdr-web-ui \
  --yes

# integrations
herdr integration install claude
# herdr integration install codex
# herdr integration install opencode
