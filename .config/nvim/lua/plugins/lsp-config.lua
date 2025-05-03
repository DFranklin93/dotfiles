return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "dockerls",
          "jsonls",
          "lua_ls",
          "rust_analyzer",
          "pylyzer",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- capabilities is for config in completions.lua 
      -- place capabilities in lspconfig to get recommendations
      -- based on language
      local capabilites = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.bashls.setup({capabilities = capabilites})
      lspconfig.dockerls.setup({capabilities = capabilites})
      lspconfig.jsonls.setup({capabilities = capabilites})
      lspconfig.lua_ls.setup({capabilities = capabilites})
      lspconfig.rust_analyzer.setup({capabilities = capabilites})
      lspconfig.pylyzer.setup({capabilities = capabilites})

      -- setup keymaps
      vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { desc = "LSP hover" })
      vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "LSP Definition" })
      vim.keymap.set({ "n" }, "<leader>lca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.dxfmt,
        },
      })

      vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP Formatter" })
    end,
  },
}
