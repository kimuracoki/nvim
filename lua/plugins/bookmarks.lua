return {

  -- ブックマーク/マーカー
  {
    "MattesGroeger/vim-bookmarks",
    config = function()
      vim.g.bookmark_sign = "󰆤"
      vim.g.bookmark_annotation_sign = "󰆥"
      vim.g.bookmark_auto_save = 1
      vim.g.bookmark_auto_close = 0
      vim.g.bookmark_manage_per_buffer = 1
      vim.g.bookmark_save_per_working_dir = 1
      vim.g.bookmark_center = 1
      vim.g.bookmark_highlight_lines = 1
      vim.g.bookmark_show_warning = 0
    end,
  },
}
