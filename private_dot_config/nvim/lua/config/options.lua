-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local function is_ssh()
  -- 普通のSSHセッション
  if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
    return true
  end

  -- 既存tmux sessionへSSHからattachした場合
  if vim.env.TMUX then
    local result = vim.fn.system({
      "tmux",
      "show-environment",
      "SSH_CONNECTION",
    })

    if vim.v.shell_error == 0 and result:match("^SSH_CONNECTION=") then
      return true
    end
  end

  return false
end

if is_ssh() then
  -- OSC52を明示的に利用
  -- SSH + tmux越しでも手元pcのclipboardへコピー可能
  -- pasteはOSC52の読み取りに応答しない端末/マルチプレクサ(herdr等)で待たされるので、
  -- nvim内の無名レジスタを返す(手元のclipboardからの貼り付けは端末のペーストで行う)
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy only)",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

-- vim.g.lazyvim_blink_main = true
-- yank/pasteでシステムクリップボードを使用する
vim.opt.clipboard = "unnamedplus"

-- prettierは設定ファイルがあるプロジェクトのみで利用
vim.g.lazyvim_prettier_needs_config = true
