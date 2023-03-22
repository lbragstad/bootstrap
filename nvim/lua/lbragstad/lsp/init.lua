local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end

configure = function ()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }
  vim.diagnostic.config(config)

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = '*.go',
    callback = function()
      vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
    end
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })

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
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.go" },
  callback = function()
	  vim.lsp.buf.format(nil, 3000)
  end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
          pattern = { "*.go" },
          callback = function()
                  local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
                  params.context = {only = {"source.organizeImports"}}

                  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
                  for _, res in pairs(result or {}) do
                          for _, r in pairs(res.result or {}) do
                                  if r.edit then
                                          vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
                                  else
                                          vim.lsp.buf.execute_command(r.command)
                                  end
                          end
                  end
          end,
  })

end

require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = { "gopls", "marksman", "pyright", "bashls" },
}
require("lsp_signature").setup()
require"lspconfig".gopls.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.marksman.setup{}
require'lspconfig'.bashls.setup{}
require'lspconfig'.tsserver.setup{}
configure()
