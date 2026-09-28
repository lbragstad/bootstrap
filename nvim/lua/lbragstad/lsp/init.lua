local status_ok, _ = pcall(require, "mason")
if not status_ok then
	return
end

local configure = function ()
  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
      },
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = true,
      header = "",
      prefix = "",
    },
  }
  vim.diagnostic.config(config)

  vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = ev.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', function()
        vim.lsp.buf.hover { border = "rounded" }
      end, opts)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.go" },
    callback = function()
      local client = vim.lsp.get_clients({ bufnr = 0, name = "gopls" })[1]
      if client then
        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }

        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
        for _, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
            elseif r.command then
              client:exec_cmd(r.command, { bufnr = 0 })
            end
          end
        end
      end

      vim.lsp.buf.format { timeout_ms = 3000 }
    end,
  })

end

require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "gopls", "marksman", "pyright", "bashls" },
    -- servers are enabled explicitly below
    automatic_enable = false,
}
require("lsp_signature").setup()

-- Server configs live in nvim-lspconfig's lsp/ directory; these tables are
-- merged on top of them. See :help lspconfig-nvim-0.11
vim.lsp.config("gopls", {
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    settings = {
      gopls = {
        buildFlags = {"-tags=compliance"},
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  })

vim.lsp.enable { "gopls", "pyright", "marksman", "bashls", "ts_ls" }

configure()
