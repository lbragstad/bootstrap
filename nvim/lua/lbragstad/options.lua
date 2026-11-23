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
--
-- foldnestmax caps how deep folds go. At 1 a function is one fold and its body
-- is flat, so opening a function shows all of it — without the cap every
-- nested loop and conditional is another fold to open. The docs scope
-- foldnestmax to the indent and syntax methods, but it clamps expr levels too.
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 0
vim.opt.foldnestmax = 1

-- Languages that nest functions inside a class or module block put their first
-- function level at depth 2, so a global cap of 1 would collapse a whole class
-- into one fold and leave its methods unfoldable. Give those one more level.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FoldNesting", { clear = true }),
  pattern = { "python" },
  callback = function()
    vim.opt_local.foldnestmax = 2
  end,
})

-- Treat hyphenated words as one word
vim.cmd [[set iskeyword+=-]]

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("AutoRefresh", { clear = true }),
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
