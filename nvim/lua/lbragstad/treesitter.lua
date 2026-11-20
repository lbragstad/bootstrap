-- nvim-treesitter's main branch dropped the nvim-treesitter.configs module and
-- its setup{} table: there is no ensure_installed, and highlight and indent are
-- no longer options but per-buffer calls. Parsers are compiled by the
-- tree-sitter CLI (installed by the neovim role) into install_dir, and the
-- playbook installs the list in nvim_treesitter_parsers.
local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
  return
end

treesitter.setup {}

-- Start treesitter per buffer, for filetypes that have a parser. vim.treesitter
-- .start throws when the parser is missing, which is the normal case for a
-- filetype that was never installed, so it stays inside a pcall: a missing
-- parser should fall back to regex syntax, not error on every BufEnter.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if not lang or not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
