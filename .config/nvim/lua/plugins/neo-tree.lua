return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "Muniftanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true, -- hide filtered items on open
            hide_gitignored = true,
            hide_dotfiles = false,
            hide_by_name = {
              ".github",
              ".prettierrc.json",
            },
            never_show = { ".git" },
          },
        },
      })

      vim.keymap.set("n", "<leader>nr", ":Neotree filesystem reveal left<CR>", { desc = "Neotree reveal left" });
      vim.keymap.set("n", "<leader>nc", ":Neotree close left<CR>", { desc = "Neotree close left" })
    end,
  }
}
