-- markdown / text ではスペルチェックを有効化（blink の spell 補完と対で使う）。
-- blink.cmp は InsertEnter 後に読まれるため、この FileType autocmd は
-- プラグインの config ではなく import 時（起動時）に登録しておく。
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
    vim.opt_local.spellsuggest = "best,20" -- spellsuggest の候補数を増やす
  end,
})

return {
  ---------------------------------------------------------------------------
  -- スニペットエンジン（LuaSnip）と VSCode 風スニペット集。blink.cmp から利用する。
  ---------------------------------------------------------------------------
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" }, -- VSCode 風のスニペット集

  ---------------------------------------------------------------------------
  -- 補完エンジン（VSCode の IntelliSense 相当）。旧 nvim-cmp から移行。
  -- Rust 製ファジーマッチャで高速。スニペットは LuaSnip を継続利用する
  -- （friendly-snippets + snippets/lua の自作スニペット）。
  ---------------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "*", -- リリースタグ = プリビルドバイナリを取得（Rust ツールチェーン不要）
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      -- markdown/text 用の英単語補完（旧 cmp-spell 相当。vim の spellsuggest を候補に出す）
      "ribru17/blink-cmp-spell",
    },
    opts = {
      snippets = {
        preset = "luasnip", -- LuaSnip に登録済みのスニペットを候補に出す
        -- blink の既定は -3。これは「Snippet 種別の候補すべて」に効くペナルティで、
        -- さらに snippets プロバイダ自体の既定 -1 と合算されて実質 -4 になる。
        -- HLS のように似た候補を大量に返す LSP があると、スニペットが
        -- 候補リストの最下層（40番目以降）に沈んで事実上見えなくなるため 0 にする。
        score_offset = 0,
      },
      -- 種別アイコン用（VSCode 風の kind アイコン。Nerd Font 前提）
      appearance = { nerd_font_variant = "mono" },
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        -- Tab: 補完表示中は次候補 / スニペット展開中はジャンプ / それ以外は既定動作
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        -- 矢印上下でも候補を選べるようにする（VSCode 相当）。preset="none" なので
        -- ここで明示しないと矢印はカーソル移動に素通りして補完が閉じてしまう。
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
      },
      completion = {
        -- 先頭候補をあらかじめ選択状態にする（旧 cmp の confirm({select=true}) 相当）。
        -- auto_insert=false なので確定するまではバッファに挿入しない。
        list = { selection = { preselect = true, auto_insert = false } },
        -- 確定前の候補を薄いインラインで先読み（VSCode のゴーストテキスト相当）
        ghost_text = { enabled = true },
        menu = {
          border = "rounded", -- 他フロートと枠を揃える
          max_height = 15,    -- blink 既定は 10。旧 nvim-cmp はもっと長く出ていたので広げる
          draw = {
            -- 種別アイコン + ラベル + ソース名（旧 lspkind の menu 表示相当）
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
      },
      sources = {
        -- 既定ソース: LSP / パス / スニペット / バッファ
        default = { "lsp", "path", "snippets", "buffer" },
        -- markdown / text では英単語（spell）補完も足す（旧 cmp-spell の filetype 設定）
        per_filetype = {
          markdown = { "lsp", "path", "snippets", "buffer", "spell" },
          text = { "lsp", "path", "snippets", "buffer", "spell" },
        },
        providers = {
          spell = { name = "Spell", module = "blink-cmp-spell" },
          -- スニペットを LSP（score_offset=0）より少しだけ上に置く。
          -- 既定の -1 のままだと LSP の候補に埋もれて表示範囲外になる。
          snippets = { score_offset = 1 },
          -- blink の既定は lsp.fallbacks = { "buffer" }、つまり LSP が1件でも
          -- 候補を返すとバッファ補完が丸ごと抑制される。旧 nvim-cmp は
          -- cmp.config.sources({lsp, luasnip, buffer, path}) で4ソースを常に
          -- 併用していたため、コメント中の単語など LSP が知らない語も出ていた。
          -- その挙動に戻すためフォールバック指定を空にする。
          lsp = { fallbacks = {} },
        },
      },
      -- ファジーマッチャは Rust 実装を使う（プリビルドバイナリ。無ければ警告して Lua 実装へ）
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    config = function(_, opts)
      -- LuaSnip にスニペットをロード（blink の luasnip preset がここから候補を拾う）
      require("luasnip.loaders.from_vscode").lazy_load()
      -- 自作スニペット（Lua 形式。展開時に定義をバッファ末尾へ足す副作用を持つため）
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets/lua" },
      })
      require("blink.cmp").setup(opts)
    end,
  },
}
