-- よく使う import。トリガは imp + モジュール名（impMap / impText など）。
--
-- 展開してもカーソル位置には何も入らず、import 群の末尾に生える。
-- 同じモジュールの行が既にあれば、そこへ名前を足してまとめる
-- （import Data.List が 2 行に分かれない）。
--
-- qualified の別名は lua/config/haskell_snippets.lua の H.imports に集約してある。
-- 定義スニペット（atcoder.lua など）が生やす import と綴りを揃えるため。

local H = require("config.haskell_snippets")

local function imp(trig, line, desc)
  return H.header(trig, { imports = { line } }, desc)
end

return {
  ---------------------------------------------------------------------------
  -- 文字列
  ---------------------------------------------------------------------------
  imp("impBS", H.imports.bs, "import: ByteString（競プロの入出力はこれ）"),
  imp("impBuilder", H.imports.builder, "import: ByteString Builder（大量出力の連結）"),
  imp("impText", H.imports.text, "import: Text（アプリ側の文字列はこれ）"),
  imp("impTextIO", H.imports.text_io, "import: Text の入出力（TIO.putStrLn など）"),
  imp("impTextEncoding", H.imports.text_encoding, "import: Text <-> ByteString の UTF-8 変換"),
  imp("impChar", "import Data.Char (ord, chr, isDigit, digitToInt, toUpper, toLower)", "import: 文字の判定・変換"),

  ---------------------------------------------------------------------------
  -- コンテナ
  ---------------------------------------------------------------------------
  imp("impMap", H.imports.map, "import: Map（正格版。遅延版は積みやすいので使わない）"),
  imp("impIntMap", H.imports.intmap, "import: IntMap（キーが Int なら Map より速い）"),
  imp("impSet", H.imports.set, "import: Set"),
  imp("impIntSet", H.imports.intset, "import: IntSet"),
  imp("impArray", "import Data.Array (Array, listArray, accumArray, bounds, elems, (!), (//))", "import: 不変配列（DP テーブル）"),
  imp("impVector", H.imports.vector, "import: Vector（Unboxed。数値の配列はこれが速い）"),
  imp("impVectorM", H.imports.vector_mut, "import: 可変 Vector（ST / IO の中で破壊的更新）"),

  ---------------------------------------------------------------------------
  -- リスト・関数
  ---------------------------------------------------------------------------
  imp("impList", "import Data.List (foldl', sort, sortOn, group, nub, transpose)", "import: リスト操作"),
  imp("impMaybe", "import Data.Maybe (fromJust, fromMaybe, mapMaybe, catMaybes)", "import: Maybe の取り回し"),
  imp("impBool", "import Data.Bool (bool)", "import: bool（if の関数版）"),
  imp("impOrd", "import Data.Ord (comparing, Down (..))", "import: 比較・降順ソート"),
  imp("impFunction", "import Data.Function (on, (&))", "import: on / (&)"),
  imp("impBits", "import Data.Bits (shiftL, shiftR, xor, popCount, testBit, (.&.), (.|.))", "import: ビット演算（bit DP）"),

  ---------------------------------------------------------------------------
  -- モナド・IO
  ---------------------------------------------------------------------------
  imp("impMonad", "import Control.Monad (replicateM, forM_, when, unless)", "import: ループと分岐"),
  imp("impIORef", "import Data.IORef (newIORef, readIORef, writeIORef, modifyIORef')", "import: IO の中の可変参照"),
  imp("impST", "import Control.Monad.ST (ST, runST)", "import: ST（局所的な破壊的更新を純粋に包む）"),
  imp("impSTRef", "import Data.STRef (newSTRef, readSTRef, writeSTRef, modifySTRef')", "import: ST の中の可変参照"),
  imp("impPrintf", "import Text.Printf (printf)", "import: printf（実数の桁指定出力）"),
}
