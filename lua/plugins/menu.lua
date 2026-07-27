return {
  -- コンテキストメニュー用のポップアップ基盤（VSCode の右クリックメニュー相当のUI）
  -- 純粋な「選ぶ」メニュー: j/k で移動・Enter で決定・右端の 1 キー(&x)でも選べる。検索窓は出ない。
  -- メニュー項目の定義とキーマップは lua/config/context_menu.lua 側に置く。
  {
    "skywind3000/vim-quickui",
    event = "VeryLazy",
    init = function()
      vim.g.quickui_border_style = 2 -- 角丸ボーダー
      -- メニュー配色を標準ハイライト群(Pmenu/PmenuSel 等)にリンクさせ、現在のカラースキーム
      -- (catppuccin など。<leader>ut で切替) と透過(highlight.lua)にそのまま追従させる。
      vim.g.quickui_color_scheme = "system"
    end,
    config = function()
      require("config.context_menu").setup()
    end,
  },
}
