-- 競プロ（AtCoder / Haskell）用スニペット。
--
-- 呼び出し側だけをカーソル位置に挿入し、足りないものを自動で補う。
--   ・定義       -> ファイル末尾
--   ・import     -> 既存の import 群の直後
--   ・LANGUAGE   -> 先頭コメント（タイトル・URL・メモ）の直後
--
--   main = do
--     as <- getInts      <- "getInts" を補完するとここに名前が入り、
--                           同時に下へ定義、上へ import が生える
--
-- import を面倒みるので、テンプレート（template/Main.hs）は main の 2 行だけで済む。
-- ByteString を使わない問題に ByteString の import が残らない。
--
-- 定義は readInt を where に閉じ込めてあるので、複数を展開しても二重定義にならない。

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local OVERLOADED = "{-# LANGUAGE OverloadedStrings #-}"
local BS = "import qualified Data.ByteString.Char8 as BS"
local FROMJUST = "import Data.Maybe (fromJust)"

-- 先頭のコメントと空行が続く範囲の行数。pragma はこの直後に置く
-- （LANGUAGE pragma は最初の宣言より前にある必要がある）。
local function header_end(lines)
  local n = 0
  for idx, l in ipairs(lines) do
    if l:match("^%s*%-%-") or l:match("^%s*$") then
      n = idx
    else
      break
    end
  end
  return n
end

-- pragma と import のうち、まだ無いものだけを先頭側へ足す。
local function ensure_header(buf, spec)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local function missing(want)
    local out = {}
    for _, l in ipairs(want or {}) do
      if not vim.tbl_contains(lines, l) then
        table.insert(out, l)
      end
    end
    return out
  end

  local pragmas, imports = missing(spec.pragmas), missing(spec.imports)
  if #pragmas == 0 and #imports == 0 then
    return
  end

  local top = header_end(lines)
  -- import は「既存の import / pragma の最後の行」の直後へ。どちらも無ければ pragma と
  -- 同じ位置に置き、あとから pragma をその上に差し込む（結果は pragma -> import の順）。
  local at = top
  for idx, l in ipairs(lines) do
    if l:match("^import ") or l:match("^{%-# LANGUAGE") then
      at = idx
    end
  end

  -- 行番号がずれないよう、下（import）から先に入れる。
  if #imports > 0 then
    local block = vim.deepcopy(imports)
    if lines[at] and lines[at]:match("^{%-# LANGUAGE") then
      table.insert(block, 1, "") -- pragma の直後なら 1 行あける
    end
    local following = lines[at + 1]
    if following and not following:match("^%s*$") then
      table.insert(block, "")
    end
    vim.api.nvim_buf_set_lines(buf, at, at, false, block)
  end
  if #pragmas > 0 then
    local block = vim.deepcopy(pragmas)
    table.insert(block, "")
    vim.api.nvim_buf_set_lines(buf, top, top, false, block)
  end
end

-- 展開時の副作用として、足りないものをバッファに書き足す。
-- 展開の最中にバッファを触ると LuaSnip の位置追跡が壊れるので vim.schedule で遅らせる。
local function grow(name, spec)
  return f(function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      ensure_header(buf, spec)
      local body = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      if body:find(name .. " ::", 1, true) then
        return -- すでに定義済み
      end
      local add = { "" }
      vim.list_extend(add, spec.def)
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, add)
    end)
    return ""
  end, {})
end

-- name を打つと name が入り、spec の中身が足される。
local function helper(name, spec, desc)
  return s({ trig = name, desc = desc }, { t(name), grow(name, spec) })
end

-- ByteString を触る定義。文字列リテラルはほぼ必ず ByteString で欲しくなるので
-- OverloadedStrings も一緒に連れてくる。
local function bs(def)
  return { pragmas = { OVERLOADED }, imports = { FROMJUST, BS }, def = def }
end

-- 上に加えて readInt を where に閉じ込める（複数展開しても二重定義にならない）。
local function bsInt(def)
  local out = vim.deepcopy(def)
  vim.list_extend(out, {
    "  where",
    "    readInt = fst . fromJust . BS.readInt",
  })
  return bs(out)
end

local function trace(fn, def)
  return { imports = { "import Debug.Trace (" .. fn .. ")" }, def = def }
end

return {
  ---------------------------------------------------------------------------
  -- 読む
  ---------------------------------------------------------------------------
  helper("getInt", bsInt({
    "getInt :: IO Int",
    "getInt = readInt <$> BS.getLine",
  }), "競プロ: 1 行に整数 1 つ  ->  N"),

  helper("getInts", bsInt({
    "getInts :: IO [Int]",
    "getInts = map readInt . BS.words <$> BS.getLine",
  }), "競プロ: 1 行に整数が並ぶ  ->  A B / A_1 ... A_N"),

  helper("ints", bsInt({
    "ints :: BS.ByteString -> [Int]",
    "ints = map readInt . BS.words",
  }), "競プロ: 読み込んだ 1 行を整数列にする"),

  helper("getIntTable", bsInt({
    "getIntTable :: Int -> IO [[Int]]",
    "getIntTable n = sequence (replicate n (map readInt . BS.words <$> BS.getLine))",
  }), "競プロ: n 行それぞれに整数が並ぶ（クエリ・行列）"),

  helper("getRestTable", bsInt({
    "getRestTable :: IO [[Int]]",
    "getRestTable = map (map readInt . BS.words) . BS.lines <$> BS.getContents",
  }), "競プロ: 行数が書かれていないとき、残り全部を行ごとの整数列で"),

  helper("getGrid", bs({
    "getGrid :: Int -> IO [BS.ByteString]",
    "getGrid n = sequence (replicate n BS.getLine)",
  }), "競プロ: n 行の文字列（グリッド）"),

  ---------------------------------------------------------------------------
  -- 書く
  ---------------------------------------------------------------------------
  helper("putInts", bs({
    "putInts :: [Int] -> IO ()",
    "putInts = BS.putStrLn . BS.unwords . map (BS.pack . show)",
  }), "競プロ: 空白区切りで 1 行に出力"),

  helper("putYesNo", {
    def = {
      "putYesNo :: Bool -> IO ()",
      'putYesNo b = putStrLn (if b then "Yes" else "No")',
    },
  }, "競プロ: Yes / No で答える"),

  ---------------------------------------------------------------------------
  -- 考える
  ---------------------------------------------------------------------------
  -- main は「読む -> 呼ぶ -> 書く」に留め、考える部分は引数を取る純粋関数にする。
  -- そうすると doctest が `solve 3 2 [1,2,3]` と読める形で書ける。
  -- doctest が拾うのは Haddock コメントの中だけなので `-- |` が要る（無いと Examples: 0）。
  s({ trig = "solve", desc = "競プロ: ロジックを純粋関数に切り出す（doctest 付き）" }, {
    t({ "-- |", "-- >>> solve " }),
    i(1, "1 2"),
    t({ "", "-- " }),
    i(2, "3"),
    t({ "", "solve :: " }),
    i(3, "Int -> Int -> Int"),
    t({ "", "solve " }),
    i(4, "a b"),
    t(" = "),
    i(0, "undefined"),
  }),

  ---------------------------------------------------------------------------
  -- 覗く
  ---------------------------------------------------------------------------
  -- oj も AtCoder も stderr は見ないので、消さずにテストも提出もできる。
  helper("dbg", trace("traceShow", {
    "-- stderr に出して、その値をそのまま返す。式の途中に挟める。",
    "dbg :: Show a => a -> a",
    "dbg x = traceShow x x",
  }), "競プロ: 式の途中の値を stderr に覗く"),

  helper("dbgM", trace("traceShowM", {
    "-- do の中で stderr に出す。",
    "dbgM :: (Applicative f, Show a) => a -> f ()",
    "dbgM = traceShowM",
  }), "競プロ: do ブロックの中で stderr に覗く"),
}
