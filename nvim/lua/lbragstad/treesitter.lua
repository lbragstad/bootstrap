local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup {
  highlight = {
    ensure_installed = "maintained",
    enable = true,
    additional_vim_regex_highlighting = true
  },
  indent = {
    enable = true
  }
}

