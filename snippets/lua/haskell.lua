-- 競プロ（AtCoder / Haskell）用スニペット。
--
-- 呼び出し側だけをカーソル位置に挿入し、定義はファイル末尾に自動で足す。
--   main = do
--     as <- getInts      <- "getInts" を補完するとここに名前が入り、
--                           同時に下へ定義が生える（既にあれば何もしない）
--
-- 定義は readInt を where に閉じ込めてあるので、複数を展開しても二重定義にならない。
-- import（Data.Maybe, Data.ByteString.Char8）はテンプレート側に常駐している。

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

-- 展開時の副作用として、定義がまだ無ければバッファ末尾に追記する。
-- 展開の最中にバッファを触ると LuaSnip の位置追跡が壊れるので vim.schedule で遅らせる。
local function with_def(name, lines)
  return f(function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local body = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      if body:find(name .. " ::", 1, true) then
        return -- すでに定義済み
      end
      local add = { "" }
      vim.list_extend(add, lines)
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, add)
    end)
    return ""
  end, {})
end

-- name を打つと name が入り、定義 lines が末尾に足される。
local function helper(name, lines, desc)
  return s({ trig = name, desc = desc }, { t(name), with_def(name, lines) })
end

local readIntWhere = {
  "  where",
  "    readInt = fst . fromJust . BS.readInt",
}

local function withReadInt(lines)
  local out = vim.deepcopy(lines)
  vim.list_extend(out, readIntWhere)
  return out
end

return {
  helper("getInt", withReadInt({
    "getInt :: IO Int",
    "getInt = readInt <$> BS.getLine",
  }), "競プロ: 1 行に整数 1 つ  ->  N"),

  helper("getInts", withReadInt({
    "getInts :: IO [Int]",
    "getInts = map readInt . BS.words <$> BS.getLine",
  }), "競プロ: 1 行に整数が並ぶ  ->  A B / A_1 ... A_N"),

  helper("ints", withReadInt({
    "ints :: BS.ByteString -> [Int]",
    "ints = map readInt . BS.words",
  }), "競プロ: 読み込んだ 1 行を整数列にする"),

  helper("getIntTable", withReadInt({
    "getIntTable :: Int -> IO [[Int]]",
    "getIntTable n = sequence (replicate n (map readInt . BS.words <$> BS.getLine))",
  }), "競プロ: n 行それぞれに整数が並ぶ（クエリ・行列）"),

  helper("getRestTable", withReadInt({
    "getRestTable :: IO [[Int]]",
    "getRestTable = map (map readInt . BS.words) . BS.lines <$> BS.getContents",
  }), "競プロ: 行数が書かれていないとき、残り全部を行ごとの整数列で"),

  helper("getGrid", {
    "getGrid :: Int -> IO [BS.ByteString]",
    "getGrid n = sequence (replicate n BS.getLine)",
  }, "競プロ: n 行の文字列（グリッド）"),

  helper("putInts", {
    "putInts :: [Int] -> IO ()",
    "putInts = BS.putStrLn . BS.unwords . map (BS.pack . show)",
  }, "競プロ: 空白区切りで 1 行に出力"),

  helper("putYesNo", {
    "putYesNo :: Bool -> IO ()",
    'putYesNo b = putStrLn (if b then "Yes" else "No")',
  }, "競プロ: Yes / No で答える"),
}
