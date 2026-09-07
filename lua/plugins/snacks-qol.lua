return {
  -- 既に導入済みの snacks.nvim の QoL モジュールを有効化する（image.lua / dashboard.lua と opts マージ）。
  -- words: カーソル下シンボルの自動ハイライト（]] / [[ で参照間を移動）
  -- scroll: スムーズスクロール / dim: 集中していない範囲を暗く（zen と併用）
  -- scratch: 使い捨てバッファ（VSCode の Scratchpad 相当）。プロジェクト＋filetype ごとに
  --   ~/.local/share/nvim/ 配下へ自動永続化されるので、閉じても再度開けば内容が残る。
  --   グローバルは wrap=false（ミニマップ対策）だが、スクラッチはメモ用途で長文を書くので
  --   このウィンドウだけ wo で折り返しを有効化する（linebreak=単語境界で折り返し）。
  {
    "folke/snacks.nvim",
    opts = {
      -- 巨大ファイル（既定 1.5MB 超）を開いたときに Treesitter / LSP / 各種装飾を切って固まらせない。
      -- ミニファイされた js やログを開くと、本体のパースだけで数秒〜数十秒フリーズしていた。
      -- 発動したバッファは filetype=bigfile になる（editor.lua の treesitter 起動は pcall で抜ける）
      bigfile = { enabled = true },
      words = { enabled = true },
      scroll = { enabled = true },
      dim = {},
      scratch = {
        enabled = true,
        win = { wo = { wrap = true, linebreak = true } },
      },
      -- gutter（行番号＋診断/mark sign＋git＋折りたたみ）を1列に統合描画する statuscolumn。
      -- 診断アイコンが行番号のすぐ左に出る VSCode 風 gutter。実際の適用は options.lua で
      -- vim.opt.statuscolumn を設定して行う（enabled だけでは自動適用されない仕様）。
      statuscolumn = { enabled = true },
    },
    keys = {
      { "<leader>uz", function() require("snacks").zen() end, desc = "UI: Zen mode" },
      { "<leader>.", function() require("snacks").scratch() end, desc = "Scratch: Toggle (スクラッチをトグル)" },
      { "<leader>S", function() require("snacks").scratch.select() end, desc = "Scratch: Select (スクラッチ一覧)" },
    },
  },
}
