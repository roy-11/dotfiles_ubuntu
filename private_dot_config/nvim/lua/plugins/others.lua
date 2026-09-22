return {
  { "inkarkat/vim-ReplaceWithRegister" }, -- visual →gr : https://github.com/LazyVim/LazyVim/discussions/1371
  {
    "andrewferrier/debugprint.nvim",
    opts = {
      keymaps = {
        normal = {
          variable_below = "<leader>;",
        },
      },
    },
  },
  { "thinca/vim-quickrun" },
}
