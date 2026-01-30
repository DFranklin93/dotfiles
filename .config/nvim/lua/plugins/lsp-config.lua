return {
	-- Mason
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
					"eslint",
					"emmet_ls",
					"jdtls",
					"jsonls",
					"lua_ls",
					"rust_analyzer",
					"pylyzer",
					"ts_ls",
				},
			})
		end,
	},

	-- Global LSP setup
	{
    "neovim/nvim-lspconfig", -- You might not even need this plugin anymore
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        
        -- Define buffer-local keymaps on attach
        local on_attach = function(client, bufnr)
            local buf_map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end
            buf_map("n", "<leader>lh", vim.lsp.buf.hover, "LSP Hover")
            buf_map("n", "<leader>ld", vim.lsp.buf.definition, "LSP Definition")
            buf_map("n", "<leader>lca", vim.lsp.buf.code_action, "LSP Code Action")
        end

        -- Setup servers with new API
        vim.lsp.config('bashls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('dockerls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('eslint', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('jsonls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('lua_ls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('rust_analyzer', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('pylyzer', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('ts_ls', { capabilities = capabilities, on_attach = on_attach })
        vim.lsp.config('emmet_ls', {
            capabilities = capabilities,
            on_attach = on_attach
        })
    end,
},

	-- nvim-jdtls for Java
	{
		"mfussenegger/nvim-jdtls",
		ft = { "java" },
		config = function()
			local jdtls = require("jdtls")

			local root_markers = { 'gradlew', 'build.gradle', 'pom.xml', '.classpath', '.project', '.git' }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      if not root_dir then
        vim.notify("jdtls: Could not find project root. Open a Java project.", vim.log.levels.ERROR)
        return
      end

			local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
			local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

			local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
			local launcher = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

			local config_os
      if vim.fn.has("mac") == 1 then
        config_os = "config_mac"
      elseif vim.fn.has("unix") == 1 then
        config_os = "config_linux"
      elseif vim.fn.has("win32") == 1 then
        config_os = "config_win"
      else
        vim.notify("jdtls: Unsupported OS", vim.log.levels.ERROR)
        return
      end

			local cmd = {
				"java",
				"-Declipse.application=org.eclipse.jdt.ls.core.id1",
				"-Dosgi.bundles.defaultStartLevel=4",
				"-Declipse.product=org.eclipse.jdt.ls.core.product",
				"-Dlog.protocol=true",
				"-Dlog.level=ALL",
				"-Xms1g",
				"--add-modules=ALL-SYSTEM",
				"--add-opens",
				"java.base/java.util=ALL-UNNAMED",
				"--add-opens",
				"java.base/java.lang=ALL-UNNAMED",
				"-jar",
				launcher,
				"-configuration",
				mason_path .. "/" .. config_os,
				"-data",
				workspace_dir,
			}

			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Attach LSP keymaps buffer-local
			local on_attach = function(client, bufnr)
				local buf_map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end
				buf_map("n", "<leader>lh", vim.lsp.buf.hover, "LSP Hover")
				buf_map("n", "<leader>ld", vim.lsp.buf.definition, "LSP Definition")
				buf_map("n", "<leader>lca", vim.lsp.buf.code_action, "LSP Code Action")
				buf_map("n", "<leader>lo", jdtls.organize_imports, "Organize Imports")
				buf_map("n", "<leader>lv", jdtls.extract_variable, "Extract Variable")
				buf_map("n", "<leader>lc", jdtls.extract_constant, "Extract Constant")
				buf_map("v", "<leader>lm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method")
			end

			jdtls.start_or_attach({
				cmd = cmd,
				root_dir = root_dir,
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { java = {} },
			})
		end,
	},

	-- Formatting with null-ls
	{
		"nvimtools/none-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.dxfmt,
					null_ls.builtins.formatting.prettier,
				},
			})
			vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP Format" })
		end,
	},
}
