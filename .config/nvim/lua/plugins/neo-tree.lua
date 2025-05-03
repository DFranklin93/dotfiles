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
      vim.keymap.set("n", "<leader>nrl", ":Neotree filesystem reveal left<CR>", { desc = "Neotree reveal left" });
      vim.keymap.set("n", "<leader>ncl", ":Neotree close left<CR>", { desc = "Neotree close left" })
    end,
  }
}
