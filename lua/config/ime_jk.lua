-- Windows: IME が ON のときに `jk` → Esc を効かせるための、AHK 常駐スクリプトへの状態通知。
--
-- 【なぜ必要か】
-- keymaps.lua の `inoremap jk <Esc>` は、IME が ON の間はそもそも発火しない。`j` も `k` も
-- Windows の IME がローマ字変換バッファに吸ってしまい、nvim までキーが届かないため
-- （nvim 側からは「何も押されていない」のと同じ）。これは nvim の設定では直せない。
--
-- そこで shift_ime.ahk（AutoHotkey 常駐、リポジトリ: Develop/shift_ime_win）が
-- IME が ON のときだけ `jk` を横取りし、IME を OFF にしてから Esc を送る。
-- ただし AHK からは「今 nvim の挿入モードにいるか」が一切見えない。Warp のウィンドウタイトルは
-- Warp が独自に付けており（AI タスク名やカレントディレクトリ）、動いているプログラムを表さない。
-- このモジュールはその見えない部分だけを状態ファイルに書き出して AHK に渡す。
--
-- 【状態ファイル】 %TEMP%\nvim_ime_jk_state
--   "1 <pid>" … AHK は jk を横取りしてよい / "0" … 横取りしてはいけない
--   pid を添えるのは、nvim が異常終了して "1" のまま残った場合に AHK 側が
--   「その pid はもう居ない」と気づけるようにするため（残骸で Warp のシェルに
--   Esc が飛ぶのを防ぐ）。
--
-- 【「横取りしてよい」の定義】
-- 「IME が無ければ nvim 自身が jk を処理していたはずの場面」に一致させる。判定は
-- モードではなく maparg でその場の実マッピングを見る。こうしておけば、TermEnter で
-- Claude / Cursor CLI / lazygit のターミナルにだけ jk を張らない keymaps.lua の除外が、
-- 二重管理なしでそのまま AHK 側にも効く（それらの端末に Esc を送ると CLI が落ちる）。

local M = {}

local STATE_FILE = (vim.env.TEMP or vim.env.TMP or "C:/Windows/Temp") .. "/nvim_ime_jk_state"

-- 書き込みは 10 バイト程度なので毎回書いてよい（挿入モードの出入りは高頻度イベントではない）。
-- 逆に「前回と同じなら書かない」キャッシュは持たない。nvim を複数立ち上げたときに
-- 自分の記憶と実ファイルの内容がズレ、必要な書き込みを飛ばす事故のほうが痛い。
local function write_state(active)
  local f = io.open(STATE_FILE, "w")
  if not f then
    return
  end
  f:write(active and ("1 " .. vim.fn.getpid()) or "0")
  f:close()
end

local function has_jk(mode)
  return vim.fn.maparg("jk", mode) ~= ""
end

-- 現在のモードから求め直す。フォーカス復帰時など「イベントの種類からは
-- 状態が決まらない」場面で使う。
local function current()
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  if m == "t" then
    return has_jk("t")
  end
  if m == "i" or m == "R" then
    return has_jk("i")
  end
  return false
end

function M.setup()
  if not require("config.platform").is_windows then
    return
  end

  local group = vim.api.nvim_create_augroup("ImeJkState", { clear = true })
  local function on(events, fn, desc)
    vim.api.nvim_create_autocmd(events, { group = group, callback = fn, desc = desc })
  end

  -- InsertEnter の時点では nvim_get_mode() がまだ挿入モードを返さないことがあるので、
  -- モードから求め直さずマッピングの有無だけを見る。
  on("InsertEnter", function()
    write_state(has_jk("i"))
  end, "IME-jk: 挿入モードに入った")

  -- TermEnter: keymaps.lua の TermEnter が jk をバッファローカルに張った「あと」に走る必要がある。
  -- 同じイベントの autocmd は登録順に実行されるため、init.lua で config.keymaps より後に
  -- setup() を呼ぶこと。
  on("TermEnter", function()
    write_state(has_jk("t"))
  end, "IME-jk: ターミナルのジョブモードに入った")

  on({ "InsertLeave", "TermLeave" }, function()
    write_state(false)
  end, "IME-jk: 挿入/ジョブモードを抜けた")

  -- 挿入モードのまま別ウィンドウ（Warp の別タブなど）へ移った場合に取り残されないようにする。
  -- ターミナルがフォーカス通知に対応していないと飛んでこないが、飛んでくる環境では
  -- タブ単位まで正確になる。
  on("FocusLost", function()
    write_state(false)
  end, "IME-jk: フォーカスを失った")

  on({ "FocusGained", "VimResume" }, function()
    write_state(current())
  end, "IME-jk: フォーカス/再開")

  on({ "VimLeavePre", "VimSuspend" }, function()
    write_state(false)
  end, "IME-jk: 終了/中断")

  -- 前回の異常終了で "1" が残っている場合に備え、起動時に必ず落としておく。
  write_state(false)
end

return M
