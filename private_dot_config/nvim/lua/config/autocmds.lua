-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ノーマルモードに戻るとき英数入力にする
if os.getenv("WAYLAND_DISPLAY") then
  vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "ノーマルモードに戻るとき英数入力にする",
    callback = function()
      vim.fn.jobstart({ "fcitx5-remote", "-c" }, { detach = true })
    end,
  })
end
