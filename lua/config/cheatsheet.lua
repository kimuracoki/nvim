-- キーマップの日本語あいまい検索（<leader>? / <leader>fk で開く）
-- 「どのキーだっけ」を、設定リポジトリを grep する代わりに nvim 内で解決するための Telescope ピッカー。
--
-- 【漏れない仕組み】ここは「日本語ラベルの辞書」であって一覧の本体ではない。
-- ピッカーは実際に登録されているキーマップ（nvim_get_keymap / バッファローカル）を必ず全件走査し、
-- 下の M.sections に載っていないものは「未分類（自動収集）」として desc のまま自動で出す。
-- したがってキーマップを足し忘れてもピッカーからは消えない。ラベルが未整備なものは
-- :KeymapAudit（<leader>ha）で一覧できるので、そこが空になるようにラベルを足していく。
local M = {}

-- セクション定義。{ title, keys = { { "キー表記", "日本語ラベル", cover = { 実キー, ... } }, ... } }
-- キー表記は SPC=<leader>、g=g プレフィックス、C-=Ctrl。
-- cover は「その一行がまとめて説明している実キー」。"SPC gp*" のような複合表記や、
-- 表記からキーを一意に決められないものはここに実キーを書く（未分類へ二重に出さないため）。
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
      { "SPC ft", "TODO コメント検索" },
      { "SPC sw", "シンボル検索（全体）" },
      { "SPC sr", "プロジェクト全体を置換（選択中は選択語で置換）" },
      { "SPC e", "ファイルツリーを開く" },
      { "SPC o", "アウトラインを開く" },
      { "C-p", "ファイル検索（VSCode の Ctrl+P）" },
      { "C-S-p", "コマンドパレット" },
      { "C-t", "最近のファイル" },
      { "C-S-o", "ファイル内シンボル" },
      { "C-S-e", "バッファ一覧" },
    },
  },
  {
    title = "Buffer / Window",
    keys = {
      { "S-h / S-l", "前 / 次のバッファへ", cover = { "H", "L" } },
      { "SPC bc", "バッファを閉じる" },
      { "SPC ba", "全バッファを閉じる" },
      { "SPC bl", "バッファ一覧" },
      { "C-h/j/k/l", "ウィンドウ間を移動（ターミナル内でも同じ）", cover = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" } },
      { "SPC w h/j/k/l", "ウィンドウの幅・高さ調整", cover = { "<leader>wh", "<leader>wj", "<leader>wk", "<leader>wl" } },
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
      { "grl", "コードレンズ実行（型など）", cover = { "grx" } },
      { "gO", "ドキュメントシンボル" },
      { "gx", "カーソル下のリンク・パスを開く" },
      { "K", "ホバー（ドキュメント表示）" },
      { "C-s", "シグネチャヘルプ（挿入・選択モード）" },
      { "SPC cf", "フォーマット" },
      { "SPC ch", "インレイヒント切替" },
      { "SPC cl", "今すぐ lint 実行" },
      { "SPC cr", "リファクタリングメニュー" },
      { "SPC ce", "関数を抽出（選択中）" },
      { "SPC cv", "変数を抽出（選択中）" },
      { "SPC ci", "変数をインライン化" },
      { "gcc / gc", "コメント切替（行 / 選択）", cover = { "gcc", "gc", "gbc", "gb" } },
      { "gco / gcO", "下 / 上にコメント行を追加して挿入", cover = { "gco", "gcO" } },
      { "gcA", "行末にコメントを追加して挿入" },
      { "gS", "一行 ⇄ 複数行トグル（引数の折り返し）" },
      { "C-Space / BS", "Treesitter 選択を拡大 / 縮小", cover = { "<C-space>", "<BS>" } },
      { "an / in", "ノードを選択（親 / 子）", cover = { "an", "in" } },
      { "[n / ]n", "前 / 次のノードへ", cover = { "[n", "]n" } },
      { "[N / ]N", "前 / 次の兄弟ノードへ", cover = { "[N", "]N" } },
      { "[C", "親スコープ（画面上部のピン留め行）へジャンプ" },
      { "% / g%", "対応する括弧へ（順 / 逆）", cover = { "%", "g%", "[%", "]%", "a%" } },
      { "zR / zM", "折り畳みを全部開く / 閉じる", cover = { "zR", "zM" } },
    },
  },
  {
    title = "Diagnostics",
    keys = {
      { "[d / ]d", "前 / 次の診断へ", cover = { "[d", "]d" } },
      { "[D / ]D", "最初 / 最後の診断へ", cover = { "[D", "]D" } },
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
      { "[c / ]c", "前 / 次の変更ハンクへ", cover = { "[c", "]c" } },
      { "SPC gp*", "PR 作成 / 一覧 / 検索", cover = { "<leader>gpc", "<leader>gpl", "<leader>gps" } },
      { "SPC gi*", "Issue 作成 / 一覧", cover = { "<leader>gic", "<leader>gil" } },
    },
  },
  {
    title = "Run",
    keys = {
      { "SPC rr", "コードを実行" },
      { "SPC rf", "ファイルを実行" },
      { "SPC rp", "プロジェクトを実行" },
      { "SPC rc", "実行ウィンドウを閉じる" },
      { "SPC rt", "just t（競プロ サンプル全件テスト）" },
      { "SPC rs", "just s（競プロ AtCoder へ提出）" },
      { "SPC rd", "just doc（競プロ doctest）" },
    },
  },
  {
    title = "Debug",
    keys = {
      { "SPC db", "ブレークポイント切替" },
      { "SPC dB", "条件付きブレークポイント" },
      { "SPC dc", "デバッグ開始 / 継続" },
      { "SPC dl", "前回の構成で実行" },
      { "SPC dr", "REPL を開く" },
      { "SPC du", "デバッグ UI 切替" },
      { "SPC dt", "デバッグを終了" },
      { "F5", "デバッグ開始 / 継続" },
      { "F1 / F2 / F3", "ステップイン / オーバー / アウト", cover = { "<F1>", "<F2>", "<F3>" } },
    },
  },
  {
    title = "Test",
    keys = {
      { "SPC Tt", "最寄りのテストを実行" },
      { "SPC TT", "ファイル全体をテスト" },
      { "SPC Td", "最寄りをデバッグ実行" },
      { "SPC Ts", "サマリーを開く" },
      { "SPC TS", "テストを停止" },
      { "SPC To", "出力を表示" },
      { "SPC Tp", "出力パネル切替" },
      { "SPC Tw", "監視実行（watch）" },
    },
  },
  {
    title = "Rest (HTTP)",
    keys = {
      { "SPC Rs", "リクエストを送信" },
      { "SPC Ra", "全リクエストを送信" },
      { "SPC Rp", "前のリクエストへ" },
      { "SPC Rn", "次のリクエストへ" },
      { "SPC Rc", "curl としてコピー" },
      { "SPC Ri", "リクエスト内容を確認" },
    },
  },
  {
    title = "AI",
    keys = {
      { "SPC ii", "Claude Code を開く" },
      { "SPC ir", "Cursor CLI を開く" },
      { "SPC ic", "Cursor CLI をプロジェクトルートで開く" },
      { "SPC is", "選択範囲を送信" },
      { "SPC im", "モデル選択" },
      { "SPC if", "フォーカス切替" },
      { "SPC il", "セッション一覧" },
      { "C-k", "Claude Code を開く（挿入モード）" },
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
      { "SPC uc", "親スコープのピン留め切替" },
      { "SPC un", "通知をすべて消す" },
      { "SPC ur", "Markdown 描画切替" },
      { "SPC uz", "Zen モード（集中表示）" },
    },
  },
  {
    title = "Translate",
    keys = {
      { "SPC tj", "日本語に翻訳" },
      { "SPC te", "英語に翻訳" },
      { "SPC tr", "英訳に置換" },
      { "SPC ts*", "今の文を翻訳 / 置換", cover = { "<leader>tsj", "<leader>tse", "<leader>tsr" } },
      { "SPC tp", "Pantran（長文翻訳）" },
    },
  },
  {
    title = "Edit / 基本",
    keys = {
      { "SPC .", "スクラッチをトグル（使い捨てバッファ）" },
      { "SPC S", "スクラッチ一覧（C-x で削除）" },
      { "SPC m", "コンテキストメニュー（右クリック相当）" },
      { "s", "どこでもジャンプ（flash）" },
      { "S", "Treesitter ノード選択（flash）" },
      { "r", "遠隔テキストオブジェクト（flash・オペレータ待ち）" },
      { "R", "Treesitter 検索（flash）" },
      { "C-s", "保存" },
      { "jk", "ノーマルモードへ" },
      { "SPC a", "全選択" },
      { "C-c", "コピー" },
      { "C-v", "貼り付け" },
      { "C-z", "元に戻す" },
      { "C-S-z", "やり直し" },
      { "C-a / C-x", "数値をインクリメント / デクリメント（dial）", cover = { "<C-a>", "<C-x>" } },
      { "M-h/j/k/l", "行 / 選択を左右上下へ移動（VSCode の Alt+↑↓ 相当）", cover = { "<M-h>", "<M-j>", "<M-k>", "<M-l>" } },
      { "gsa", "囲みを追加（例: gsaiw\" で単語を \" で囲む）" },
      { "gsd", "囲みを削除", cover = { "gsdl", "gsdn" } },
      { "gsr", "囲みを置換", cover = { "gsrl", "gsrn" } },
      { "gsf / gsF", "囲みの右 / 左へ移動", cover = { "gsf", "gsF", "gsfl", "gsfn", "gsFl", "gsFn" } },
      { "gsh", "囲みをハイライト", cover = { "gshl", "gshn" } },
      { "af / if", "関数を選択（外側 / 内側・mini.ai）", cover = { "a", "i", "al", "il" } },
      { "g[ / g]", "テキストオブジェクトの端へ移動", cover = { "g[", "g]" } },
      { "g C-a / g C-x", "連番でインクリメント / デクリメント（選択範囲）", cover = { "g<C-a>", "g<C-x>" } },
      { "[Space / ]Space", "上 / 下に空行を追加", cover = { "[ ", "] " } },
      { "C-\\", "ターミナルをトグル" },
      { "Esc", "ターミナルをノーマルモードへ（Claude/lazygit は透過）", cover = { "<Esc>" } },
      { "Tab / S-Tab", "スニペットの次 / 前のプレースホルダへ", cover = { "<Tab>", "<S-Tab>" } },
      { "C-w d", "カーソル位置の診断を表示", cover = { "<C-w>d", "<C-w><C-d>" } },
    },
  },
  {
    title = "Bookmark / Todo",
    keys = {
      { "mm", "ブックマークをトグル" },
      { "mi", "ブックマークに注釈を付ける" },
      { "mn / mp", "次 / 前のブックマークへ", cover = { "mn", "mp" } },
      { "ma", "ブックマーク一覧" },
      { "mc / mx", "ブックマークを削除（この行 / 全部）", cover = { "mc", "mx" } },
      { "mg", "指定行のブックマークへ移動" },
      { "mjj / mkk", "ブックマークを下 / 上へ移動", cover = { "mjj", "mkk" } },
      { "[t / ]t", "前 / 次の TODO コメントへ", cover = { "[t", "]t" } },
    },
  },
  {
    title = "Misc",
    keys = {
      { "SPC hc", "Checkhealth" },
      { "SPC hm", "通知ログ（見逃した通知を読む・コピーできる）" },
      { "SPC hn", "noice の履歴" },
      { "SPC ha", "キーマップ棚卸し（日本語ラベル未登録の一覧）" },
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

-- 表示表記 / vim 表記を「実キーのバイト列」に正規化する。
-- <C-p> と <C-P>、"SPC ff" と " ff" のような表記ゆれを吸収して突き合わせるために使う。
local function canon(s)
  if s:sub(1, 4) == "SPC " then
    s = "<leader>" .. s:sub(5)
  end
  s = s:gsub("<[lL]eader>", vim.g.mapleader or " ")
  if s:match("^[CSM]%-%S+$") or s:match("^F%d+$") then
    s = "<" .. s .. ">" -- "C-p" / "F5" のような裸表記を <C-p> / <F5> に揃える
  end
  local ok, res = pcall(vim.api.nvim_replace_termcodes, s, true, true, true)
  return ok and res or s
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
  if disp:match("^C%-[%w%-S\\]+$") or disp:match("^S%-%w$") or disp:match("^F%d$") then
    return "<" .. disp .. ">" -- "C-s" / "C-S-z" / "S-h" / "F5"
  end
  if disp:match("^[gK%[%]][%w%[%]]*$") then
    return disp -- "gd" / "K" / "[d" など
  end
  if disp:match("^[msSrRz]%w*$") then
    return disp -- "mm" / "s" / "zR" など
  end
  return nil
end

-- 一覧に出さない実キー（内部用・Neovim 既定のヘルプ参照だけのもの）
local function is_noise(lhs, desc)
  if lhs == "" or lhs:find("<Plug>", 1, true) or lhs:find("<SNR>", 1, true) then
    return true
  end
  if desc:match("^:") then
    return true -- ":help Y-default" / ":cnext" 等、Neovim 既定の定義
  end
  if desc == "which-key-trigger" then
    return true -- which-key がプレフィックス表示用に張る内部マップ
  end
  return false
end

-- M.sections が説明している実キーの集合
local function covered_set()
  local set = {}
  for _, sec in ipairs(M.sections) do
    for _, item in ipairs(sec.keys) do
      if not item[1]:find("[/*]") then
        set[canon(item[1])] = true
      end
      for _, c in ipairs(item.cover or {}) do
        set[canon(c)] = true
      end
    end
  end
  return set
end

-- 実際に登録されているキーマップのうち、M.sections が説明していないもの。
-- 「ラベルの付け忘れ」がここに溜まる（:KeymapAudit で確認できる）。
function M.uncovered()
  local covered = covered_set()
  local seen, out = {}, {}
  local leader = vim.g.mapleader or " "

  local function collect(maps, scope)
    for _, m in ipairs(maps) do
      local lhs, desc = m.lhs or "", m.desc or ""
      if not is_noise(lhs, desc) then
        local key = canon(lhs)
        if not covered[key] and not seen[key] then
          seen[key] = true
          local disp = lhs
          if leader ~= "" and disp:sub(1, #leader) == leader then
            disp = "SPC " .. disp:sub(#leader + 1)
          end
          out[#out + 1] = {
            key = disp,
            desc = desc ~= "" and desc or "(説明なし)",
            mode = m.mode or "",
            scope = scope,
            keys = (m.mode == "n" or m.mode == " ") and lhs or nil,
          }
        end
      end
    end
  end

  -- バッファローカルは「実ファイルのバッファ」だけ見る。telescope や通知ログのような
  -- プラグイン UI バッファには q / <Esc> といったその場限りのキーが張られていて、
  -- 一覧に入れても意味が無いうえ棚卸しのノイズになる。
  local is_file_buf = vim.bo.buftype == ""
  for _, mode in ipairs({ "n", "x", "v", "o", "i", "t" }) do
    collect(vim.api.nvim_get_keymap(mode), "global")
    if is_file_buf then
      collect(vim.api.nvim_buf_get_keymap(0, mode), "buffer")
    end
  end
  table.sort(out, function(a, b)
    return a.key < b.key
  end)
  return out
end

-- セクション定義 + 未分類（自動収集）を { category, key, desc, keys } のフラットな配列にする
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
  -- ラベル未登録のキーマップも必ず出す（検索から漏れないようにするための保険）
  for _, e in ipairs(M.uncovered()) do
    out[#out + 1] = {
      category = e.scope == "buffer" and "未分類（このバッファ）" or "未分類（自動収集）",
      key = e.key,
      desc = e.desc .. (e.mode ~= "" and e.mode ~= "n" and (" [" .. e.mode .. "]") or ""),
      keys = e.keys,
    }
  end
  return out
end

-- 日本語ラベルが未登録のキーマップを一覧表示する（:KeymapAudit / <leader>ha）。
-- ここが空＝キーマップ検索に漏れが無い状態。
function M.audit()
  local list = M.uncovered()
  if #list == 0 then
    vim.notify("キーマップ棚卸し: 日本語ラベル未登録なし（漏れ 0 件）", vim.log.levels.INFO)
    return list
  end
  local lines = { ("日本語ラベル未登録: %d 件（cheatsheet.lua の M.sections に追記してください）"):format(#list), "" }
  for _, e in ipairs(list) do
    lines[#lines + 1] = ("  %s %s %s"):format(pad(e.key, 18), pad("[" .. e.mode .. "]", 5), e.desc)
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "KeymapAudit" })
  return list
end

-- ヘッドレスでの確認用（nvim --headless -c 'lua print(require("config.cheatsheet").audit_report())' -c qa）
function M.audit_report()
  local list = M.uncovered()
  local lines = {}
  for _, e in ipairs(list) do
    lines[#lines + 1] = ("%s\t[%s]\t%s"):format(e.key, e.mode, e.desc)
  end
  return ("uncovered=%d\n%s"):format(#list, table.concat(lines, "\n"))
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
      { width = 20 },
      { width = 17 },
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
