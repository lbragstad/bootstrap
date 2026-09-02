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

-- Treat hyphenated words as one word
vim.cmd [[set iskeyword+=-]]

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("AutoRefresh", { clear = true }),
  command = "if mode() != 'c' | checktime | endif",
  pattern = "*",
})
