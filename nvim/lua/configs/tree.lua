require("nvim-tree").setup {
  filters = { custom = { "^.git$" } },
  disable_netrw = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  hijack_cursor = true,
  sync_root_with_cwd = true,
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      show = {
        file = false,
        folder = true,
        folder_arrow = false,
        git = false,
      },
      git_placement = "signcolumn",
    },
  },
}
