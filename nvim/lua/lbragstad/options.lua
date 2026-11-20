vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.autoread = true
vim.opt.backup = false
vim.opt.smartcase = true
vim.opt.ruler = true
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.scrolloff = 100
vim.opt.cmdheight = 1
vim.opt.background = 'dark'

-- Folding (treesitter-based). Files open as an outline: foldlevelstart closes
-- every fold, leaving top-level declarations and their signatures visible.
-- zR opens everything, za toggles the fold under the cursor. Filetypes with no
-- parser installed (see nvim_treesitter_parsers) compute no folds and open
-- normally.
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 0

-- Treat hyphenated words as one word
vim.cmd [[set iskeyword+=-]]

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("AutoRefresh", { clear = true }),
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
