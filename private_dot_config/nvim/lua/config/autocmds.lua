-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ノーマルモードに戻るとき英数入力にする
-- fcitx5-remote は D-Bus 経由なので WAYLAND_DISPLAY が無い環境(herdr/SSH 経由など)でも動く
if vim.fn.executable("fcitx5-remote") == 1 then
  vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "ノーマルモードに戻るとき英数入力にする",
    callback = function()
      vim.fn.jobstart({ "fcitx5-remote", "-c" }, { detach = true })
    end,
  })
end
