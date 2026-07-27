-- キーマップの日本語あいまい検索（<leader>? で開く）
-- 「どのキーだっけ」を、設定リポジトリを grep する代わりに nvim 内で解決するための Telescope ピッカー。
-- 表示専用の簡潔な日本語ラベルを持つ（which-key の desc とは別管理）。キーマップを足したら
-- whichkey.lua / keymaps.lua と一緒にここへも一行足す。
local M = {}

-- セクション定義。{ title, keys = { { "キー表記", "日本語ラベル" }, ... } }
-- キー表記は SPC=<leader>、g=g プレフィックス、C-=Ctrl。
M.sections = {
  {
    title = "Find / File",
    keys = {
      { "SPC ff", "ファイル検索" },
      { "SPC fg", "全文検索（grep）" },
      { "SPC fr", "最近のファイル" },
      { "SPC fb", "バッファ一覧" },
      { "SPC fc", "コマンド一覧" },
      { "SPC fk", "キーマップを検索" },
      { "SPC fs", "シンボル検索（ファイル内）" },
      { "SPC sw", "シンボル検索（全体）" },
      { "SPC e", "ファイルツリーを開く" },
      { "SPC o", "アウトラインを開く" },
    },
  },
  {
    title = "Buffer / Window",
    keys = {
      { "S-h / S-l", "前 / 次のバッファへ" },
      { "SPC bc", "バッファを閉じる" },
      { "SPC ba", "全バッファを閉じる" },
      { "C-h/j/k/l", "ウィンドウ間を移動" },
      { "SPC w h/j/k/l", "ウィンドウの幅・高さ調整" },
      { "SPC ww", "レイアウトを組む" },
      { "SPC q", "終了" },
    },
  },
  {
    title = "Code / LSP",
    keys = {
      { "gd", "定義へジャンプ" },
      { "gD", "宣言へジャンプ" },
      { "gri", "実装へジャンプ" },
      { "grt", "型定義へジャンプ" },
      { "grr", "参照を検索" },
      { "grn", "リネーム" },
      { "gra", "コードアクション" },
      { "grl", "コードレンズ実行（型など）" },
      { "gO", "ドキュメントシンボル" },
      { "K", "ホバー（ドキュメント表示）" },
      { "SPC cf", "フォーマット" },
      { "SPC ch", "インレイヒント切替" },
      { "gcc / gc", "コメント切替（行 / 選択）" },
    },
  },
  {
    title = "Diagnostics",
    keys = {
      { "[d / ]d", "前 / 次の診断へ" },
      { "SPC xd", "カーソル位置の診断" },
      { "SPC xx", "バッファの診断一覧" },
      { "SPC xw", "ワークスペースの診断" },
      { "SPC xq", "Quickfix 一覧" },
    },
  },
  {
    title = "Git",
    keys = {
      { "SPC gg", "Lazygit を開く" },
      { "SPC gs", "ハンクをステージ" },
      { "SPC gr", "ハンクをリセット" },
      { "SPC gv", "ハンクをプレビュー" },
      { "SPC gu", "ステージを取り消し" },
      { "SPC gb", "行の Blame 表示" },
      { "SPC gd", "Diff を開く" },
      { "SPC gD", "Diff を閉じる" },
      { "SPC ge", "変更ファイル一覧" },
      { "SPC gh", "ファイル履歴" },
      { "SPC gl", "コミットグラフ" },
      { "SPC go", "Octo メニュー" },
      { "SPC gp*", "PR 作成 / 一覧 / 検索" },
      { "SPC gi*", "Issue 作成 / 一覧" },
    },
  },
  {
    title = "Run / Debug",
    keys = {
      { "SPC rr", "コードを実行" },
      { "SPC rf", "ファイルを実行" },
      { "SPC rp", "プロジェクトを実行" },
      { "SPC rt", "just t（サンプルテスト）" },
      { "SPC rc", "実行ウィンドウを閉じる" },
      { "SPC db", "ブレークポイント切替" },
    },
  },
  {
    title = "AI",
    keys = {
      { "SPC ii", "Claude Code を開く" },
      { "SPC ir", "Cursor CLI を開く" },
      { "SPC is", "選択範囲を送信" },
      { "SPC im", "モデル選択" },
      { "SPC if", "フォーカス切替" },
      { "SPC il", "セッション一覧" },
    },
  },
  {
    title = "UI / 外観",
    keys = {
      { "SPC ut", "テーマ（カラースキーム）切替" },
      { "SPC uo", "透過切替" },
      { "SPC ud", "診断のインライン展開切替" },
      { "SPC ug", "ネスト背景ガイド切替" },
      { "SPC um", "ミニマップ切替" },
      { "SPC uw", "折り返し切替" },
    },
  },
  {
    title = "Translate",
    keys = {
      { "SPC tj", "日本語に翻訳" },
      { "SPC te", "英語に翻訳" },
      { "SPC tr", "英訳に置換" },
      { "SPC ts*", "今の文を翻訳 / 置換" },
      { "SPC tp", "Pantran（長文翻訳）" },
    },
  },
  {
    title = "Edit / 基本",
    keys = {
      { "s", "どこでもジャンプ（flash）" },
      { "S", "Treesitterノード選択（flash）" },
      { "C-s", "保存" },
      { "jk", "ノーマルモードへ" },
      { "C-a", "全選択" },
      { "C-c", "コピー" },
      { "C-v", "貼り付け" },
      { "C-z", "元に戻す" },
      { "C-S-z", "やり直し" },
    },
  },
  {
    title = "Misc",
    keys = {
      { "SPC hc", "Checkhealth" },
      { "SPC hm", "メッセージログ" },
      { "SPC ll", "Lazy（プラグイン状態）" },
      { "SPC ls", "Lazy 同期" },
      { "SPC ?", "キーマップ検索（この画面）" },
    },
  },
}

local function dw(s)
  return vim.fn.strdisplaywidth(s)
end

-- 表示幅で右パディングして幅を width に揃える
local function pad(s, width)
  local w = dw(s)
  if w >= width then
    return s .. " "
  end
  return s .. string.rep(" ", width - w)
end

-- 表示キー（"SPC ff" など）を feedkeys 可能な実シーケンスに変換する。
-- 複合表記（"SPC gs / gr" や "C-h/j/k/l"）は一意に定まらないので nil を返し、実行はしない。
local function to_keys(disp)
  if disp:find("[/*]") then
    return nil
  end
  local rest = disp:match("^SPC%s+(%S+)$") -- "SPC ff" → " ff"（leader = space）
  if rest then
    return " " .. rest
  end
  if disp:match("^C%-[%w%-S]+$") or disp:match("^S%-%w$") then
    return "<" .. disp .. ">" -- "C-s" / "C-S-z" / "S-h"
  end
  if disp:match("^[gK%[%]][%w%[%]]*$") then
    return disp -- "gd" / "K" / "[d" など
  end
  return nil
end

-- セクション定義を { category, key, desc, keys(実シーケンス or nil) } のフラットな配列にする
function M.flatten()
  local out = {}
  for _, sec in ipairs(M.sections) do
    for _, item in ipairs(sec.keys) do
      out[#out + 1] = {
        category = sec.title,
        key = item[1],
        desc = item[2],
        keys = to_keys(item[1]),
      }
    end
  end
  return out
end

-- キーマップを日本語ラベルであいまい検索する Telescope ピッカー。
-- 開いた時点で全件が並ぶので俯瞰にも使える。Enter で、キーが一意に定まるものはそのまま実行し、
-- 複合キー（"SPC gs / gr" 等）は通知でキーを表示する。
function M.pick()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("telescope が見つかりません", vim.log.levels.WARN)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  -- カテゴリ / キー / 説明の 3 カラムを揃えて表示する
  local displayer = entry_display.create({
    separator = "  ",
    items = {
      { width = 16 },
      { width = 15 },
      { remaining = true },
    },
  })

  pickers
    .new({}, {
      prompt_title = "キーマップ検索（日本語OK・Enterで実行）",
      finder = finders.new_table({
        results = M.flatten(),
        entry_maker = function(e)
          return {
            value = e,
            display = function(entry)
              return displayer({
                { entry.value.category, "TelescopeResultsComment" },
                { entry.value.key, "TelescopeResultsIdentifier" },
                entry.value.desc,
              })
            end,
            ordinal = e.desc .. " " .. e.key .. " " .. e.category,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not sel then
            return
          end
          local e = sel.value
          if e.keys then
            local tc = vim.api.nvim_replace_termcodes(e.keys, true, false, true)
            vim.api.nvim_feedkeys(tc, "m", false) -- remap 有効で leader/g 系マップを発火
          else
            vim.notify(("キー: %s   （%s）"):format(e.key, e.desc), vim.log.levels.INFO)
          end
        end)
        return true
      end,
    })
    :find()
end

-- 後方互換: 旧 <leader>? の一覧は検索ピッカーに統合した
M.open = M.pick

return M
