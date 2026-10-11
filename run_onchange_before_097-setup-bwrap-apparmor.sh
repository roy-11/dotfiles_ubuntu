#!/usr/bin/env bash

# Claude Code の sandbox（bubblewrap）が入れ子の user namespace を作れるようにする。
# Ubuntu 標準の bwrap-userns-restrict は子プロセスを unpriv_bwrap に落として
# ケーパビリティを外すため、sandbox 内の apply-seccomp が失敗する。
# 同名の bwrap プロファイルが衝突するので、標準側を無効化してから置き換える。

set -euo pipefail

if [[ ! -x /usr/bin/bwrap || ! -d /etc/apparmor.d ]]; then
  echo "bwrap or AppArmor not found. Skipping." >&2
  exit 0
fi

STOCK=/etc/apparmor.d/bwrap-userns-restrict
if [[ -f "$STOCK" && ! -e /etc/apparmor.d/disable/bwrap-userns-restrict ]]; then
  sudo ln -s "$STOCK" /etc/apparmor.d/disable/bwrap-userns-restrict
  sudo apparmor_parser -R "$STOCK" || true
fi

sudo tee /etc/apparmor.d/bwrap >/dev/null <<'PROFILE'
abi <abi/4.0>,
include <tunables/global>

profile bwrap /usr/bin/bwrap flags=(unconfined) {
  userns,
  include if exists <local/bwrap>
}
PROFILE
sudo chmod 644 /etc/apparmor.d/bwrap
sudo apparmor_parser -r /etc/apparmor.d/bwrap

# sandbox と同じく bwrap の中で、さらに userns を作れるか確認する
if ! bwrap --ro-bind / / --dev /dev --proc /proc --unshare-user \
  unshare --user --map-root-user true; then
  echo "Nested user namespace check failed." >&2
  exit 1
fi
