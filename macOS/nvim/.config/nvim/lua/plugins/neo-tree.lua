return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      git_status_async = false,
      default_component_configs = {
        git_status = {
          symbols = {},
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        components = {
          git_status = function()
            return {}
          end,
          diagnostics = function()
            return {}
          end,
        },
      },
    },
  },
}
