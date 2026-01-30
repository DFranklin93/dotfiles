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
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldcolumn = "1"
      vim.opt.foldtext = ""

      -- Open all folds by default
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}
