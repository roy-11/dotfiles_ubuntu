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
  vim.g.clipboard = "osc52"
end

-- vim.g.lazyvim_blink_main = true
-- yank/pasteでシステムクリップボードを使用する
vim.opt.clipboard = "unnamedplus"

-- prettierは設定ファイルがあるプロジェクトのみで利用
vim.g.lazyvim_prettier_needs_config = true
