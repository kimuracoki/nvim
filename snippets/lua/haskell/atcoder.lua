-- 競プロ（AtCoder）用スニペット。入出力とデバッグ表示。
--
-- 名前を補完するとカーソル位置には名前だけが入り、定義はファイル末尾、import は
-- import 群の直後に生える（仕組みは lua/config/haskell_snippets.lua）。
-- deps を辿るので、getInts を出せば ints と readInt も一緒に付いてくる。

local H = require("config.haskell_snippets")

local BS = H.imports.bs
local FROMJUST = "import Data.Maybe (fromJust)"
local REPLICATEM = "import Control.Monad (replicateM)"

return {
  ---------------------------------------------------------------------------
  -- 読む
  ---------------------------------------------------------------------------
  H.snip("readInt", {
    imports = { BS, FROMJUST },
    def = {
      "readInt :: BS.ByteString -> Int",
      "readInt = fst . fromJust . BS.readInt",
    },
  }, "競プロ: ByteString を Int に（read より速い定番）"),

  H.snip("ints", {
    imports = { BS },
    deps = { "readInt" },
    def = {
      "ints :: BS.ByteString -> [Int]",
      "ints = map readInt . BS.words",
    },
  }, "競プロ: 読み込んだ 1 行を整数列にする"),

  H.snip("getInt", {
    imports = { BS },
    deps = { "readInt" },
    def = {
      "getInt :: IO Int",
      "getInt = readInt <$> BS.getLine",
    },
  }, "競プロ: 1 行に整数 1 つ  ->  N"),

  H.snip("getInts", {
    imports = { BS },
    deps = { "ints" },
    def = {
      "getInts :: IO [Int]",
      "getInts = ints <$> BS.getLine",
    },
  }, "競プロ: 1 行に整数が並ぶ  ->  A B / A_1 ... A_N"),

  H.snip("getInt2", {
    deps = { "getInts" },
    def = {
      "getInt2 :: IO (Int, Int)",
      "getInt2 = do",
      "  [a, b] <- getInts",
      "  pure (a, b)",
    },
  }, "競プロ: 1 行の 2 整数をタプルで  ->  (a, b) <- getInt2"),

  H.snip("getInt3", {
    deps = { "getInts" },
    def = {
      "getInt3 :: IO (Int, Int, Int)",
      "getInt3 = do",
      "  [a, b, c] <- getInts",
      "  pure (a, b, c)",
    },
  }, "競プロ: 1 行の 3 整数をタプルで  ->  (a, b, c) <- getInt3"),

  H.snip("getWords", {
    imports = { BS },
    def = {
      "getWords :: IO [BS.ByteString]",
      "getWords = BS.words <$> BS.getLine",
    },
  }, "競プロ: 1 行に文字列が並ぶ（S T など）"),

  H.snip("getIntTable", {
    imports = { REPLICATEM },
    deps = { "getInts" },
    def = {
      "getIntTable :: Int -> IO [[Int]]",
      "getIntTable n = replicateM n getInts",
    },
  }, "競プロ: n 行それぞれに整数が並ぶ（クエリ・行列）"),

  H.snip("getRestTable", {
    imports = { BS },
    deps = { "ints" },
    def = {
      "getRestTable :: IO [[Int]]",
      "getRestTable = map ints . BS.lines <$> BS.getContents",
    },
  }, "競プロ: 行数が書かれていないとき、残り全部を行ごとの整数列で"),

  H.snip("getGrid", {
    imports = { BS, REPLICATEM },
    def = {
      "getGrid :: Int -> IO [BS.ByteString]",
      "getGrid n = replicateM n BS.getLine",
    },
  }, "競プロ: n 行の文字列（グリッド）"),

  ---------------------------------------------------------------------------
  -- 書く
  ---------------------------------------------------------------------------
  H.snip("bshow", {
    imports = { BS },
    def = {
      "bshow :: Show a => a -> BS.ByteString",
      "bshow = BS.pack . show",
    },
  }, "競プロ: show して ByteString に"),

  H.snip("putInts", {
    imports = { BS },
    deps = { "bshow" },
    def = {
      "putInts :: [Int] -> IO ()",
      "putInts = BS.putStrLn . BS.unwords . map bshow",
    },
  }, "競プロ: 空白区切りで 1 行に出力"),

  H.snip("putIntsLines", {
    imports = { BS },
    deps = { "bshow" },
    def = {
      "-- 1 行 1 個をまとめて出す。答えを print で 1 行ずつ書くと出力が多いとき遅い。",
      "putIntsLines :: [Int] -> IO ()",
      "putIntsLines = BS.putStr . BS.unlines . map bshow",
    },
  }, "競プロ: 1 行 1 個で大量出力（print の繰り返しより速い）"),

  H.snip("putYesNo", {
    imports = { "import Data.Bool (bool)" },
    def = {
      "putYesNo :: Bool -> IO ()",
      'putYesNo = putStrLn . bool "No" "Yes"',
    },
  }, "競プロ: Yes / No で答える"),

  ---------------------------------------------------------------------------
  -- 覗く
  ---------------------------------------------------------------------------
  -- oj も AtCoder も stderr は見ないので、消さずにテストも提出もできる。
  H.snip("dbg", {
    imports = { "import Debug.Trace (traceShow)" },
    def = {
      "-- stderr に出して、その値をそのまま返す。式の途中に挟める。",
      "dbg :: Show a => a -> a",
      "dbg x = traceShow x x",
    },
  }, "競プロ: 式の途中の値を stderr に覗く"),

  H.snip("dbgM", {
    imports = { "import Debug.Trace (traceShowM)" },
    def = {
      "-- do の中で stderr に出す。",
      "dbgM :: (Applicative f, Show a) => a -> f ()",
      "dbgM = traceShowM",
    },
  }, "競プロ: do ブロックの中で stderr に覗く"),
}
