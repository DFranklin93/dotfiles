return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",                     -- Automatically update Treesitter parsers
    event = { "BufReadPost", "BufNewFile" }, -- Load only when needed
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        ensure_installed = { "markdown", "markdown_inline" },
        highlight = { enable = true },
        compilers = { "clang" },
      })
    end,
  },
}
