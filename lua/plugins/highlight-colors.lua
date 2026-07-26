return {
  ---------------------------------------------------------------------------
  -- カラーコードの横に色見本の四角（VSCode風）
  ---------------------------------------------------------------------------
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-highlight-colors").setup({
        render = "virtual",              -- 横に四角だけ表示（'background'|'foreground'|'virtual'）
        virtual_symbol = "■",
        virtual_symbol_prefix = "",
        virtual_symbol_suffix = " ",
        virtual_symbol_position = "inline", -- VSCode 風にカラーコードの横に表示
        enable_hex = true,
        enable_short_hex = true,
        enable_rgb = true,
        enable_hsl = true,
        enable_named_colors = true,
        enable_tailwind = false,
      })
    end,
  },
}
