vim.filetype.add({
  pattern = {
    [".*%.blade%.php"] = "blade",
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "blade" } },
  },
}
