return {
  -- Markdown のインライン整形描画（VSCode の Markdown プレビューを別ウィンドウでなく本文上に重ねる）。
  -- 見出し・箇条書き・表・コードブロック・チェックボックスを装飾表示する。画像は snacks 側で対応済み。
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "octo", "codecompanion" },
    opts = {
      -- 挿入モードでは生の Markdown を見せ、ノーマルモードで整形表示（編集しやすさ優先）
      render_modes = { "n", "c", "t" },
      file_types = { "markdown", "octo", "codecompanion" },
    },
    keys = {
      { "<leader>ur", "<cmd>RenderMarkdown toggle<cr>", desc = "UI: Markdown render toggle (Markdown 描画のトグル)" },
    },
  },
}
