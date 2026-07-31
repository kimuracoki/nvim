-- LANGUAGE / OPTIONS_GHC プラグマ。トリガは拡張名そのもの（LambdaCase など）。
--
-- 展開してもカーソル位置には何も入らない。プラグマは「最初の宣言より前」でなければ
-- ならないので、書いている場所に関係なくファイル先頭（先頭コメントの直後）へ生える。
-- 同じ拡張が別の行（`{-# LANGUAGE Foo, Bar #-}`）で有効なら何もしない。
--
-- 綴りを 1 文字間違えると GHC が黙って無視する（-Wunrecognised-pragmas を付けないと
-- 警告も出ない）ので、手打ちせずここから出すのが安全。

local H = require("config.haskell_snippets")

local function lang(ext, desc)
  return H.header(ext, { pragmas = { ("{-# LANGUAGE %s #-}"):format(ext) } }, desc)
end

local function opt(trig, flag, desc)
  return H.header(trig, { pragmas = { ("{-# OPTIONS_GHC %s #-}"):format(flag) } }, desc)
end

return {
  ---------------------------------------------------------------------------
  -- GHC2021 に入っていない拡張（単体ファイルでも書かないと有効にならない）
  ---------------------------------------------------------------------------
  lang("LambdaCase", "pragma: \\case が書ける（GHC2024 で標準化。9.4 では明示が必要）"),
  lang("MultiWayIf", "pragma: if | 条件 -> ... の多分岐"),
  lang("OverloadedStrings", "pragma: 文字列リテラルを Text / ByteString として書ける"),
  lang("RecordWildCards", "pragma: Foo{..} でフィールドを一括束縛"),
  lang("ViewPatterns", "pragma: パターンの中で関数を適用（f -> x）"),
  lang("BlockArguments", "pragma: when cond do ... の括弧・$ を省ける"),
  lang("StrictData", "pragma: データ型のフィールドを既定で正格に"),
  lang("Strict", "pragma: モジュール全体を正格に（サンク肥大の回避）"),
  lang("OverloadedRecordDot", "pragma: x.field でフィールドアクセス（GHC 9.2+）"),
  lang("DerivingStrategies", "pragma: deriving stock / newtype / anyclass を明示"),
  lang("DerivingVia", "pragma: deriving via で他の型の実装を借りる"),
  lang("DeriveAnyClass", "pragma: 既定実装だけのクラスを deriving で導出"),
  lang("GADTs", "pragma: GADT（GHC2021 は構文だけで、型検査には別途これが要る）"),
  lang("DataKinds", "pragma: 値レベルの型を型レベルへ持ち上げる"),
  lang("TypeFamilies", "pragma: 型族（型レベルの関数）"),
  lang("TemplateHaskell", "pragma: コンパイル時のコード生成（$(...) / [| |]）"),

  ---------------------------------------------------------------------------
  -- GHC2021 には含まれる拡張。
  -- 単体ファイル（GHC 9.2+）なら不要だが、cabal が default-language: Haskell2010 を
  -- 指定しているプロジェクトでは明示が要るので置いてある。
  ---------------------------------------------------------------------------
  lang("BangPatterns", "pragma: !x で正格評価（GHC2021 なら不要）"),
  lang("TupleSections", "pragma: (, x) の部分適用（GHC2021 なら不要）"),
  lang("ScopedTypeVariables", "pragma: forall した型変数を本体でも使う（GHC2021 なら不要）"),
  lang("TypeApplications", "pragma: read @Int の型適用（GHC2021 なら不要）"),
  lang("ImportQualifiedPost", "pragma: import Data.Map qualified as M（GHC2021 なら不要）"),

  ---------------------------------------------------------------------------
  -- コンパイラオプション
  ---------------------------------------------------------------------------
  opt("optWall", "-Wall", "pragma: このファイルだけ警告を全部出す"),
  opt("optO2", "-O2", "pragma: このファイルだけ最適化を上げる"),
}
