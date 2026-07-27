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
      snippets = { preset = "luasnip" }, -- LuaSnip に登録済みのスニペットを候補に出す
      -- 種別アイコン用（VSCode 風の kind アイコン。Nerd Font 前提）
      appearance = { nerd_font_variant = "mono" },
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        -- Tab: 補完表示中は次候補 / スニペット展開中はジャンプ / それ以外は既定動作
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
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
