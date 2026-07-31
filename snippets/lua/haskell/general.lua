-- 競プロ以外（アプリ・ライブラリ）の Haskell 開発でよく書くもの。
--
-- data / newtype / instance / module といった構文の型そのものは friendly-snippets の
-- haskell.json が持っている（data record / new / inst / mods など）ので、ここには
-- 「pragma や import が付いてこないと書けないもの」だけを置く。

local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node

local H = require("config.haskell_snippets")

local DERIVING_STRATEGIES = "{-# LANGUAGE DerivingStrategies #-}"

return {
  ---------------------------------------------------------------------------
  -- Text
  ---------------------------------------------------------------------------
  H.snip("tshow", {
    imports = { H.imports.text },
    def = {
      "tshow :: Show a => a -> T.Text",
      "tshow = T.pack . show",
    },
  }, "Text: show の結果を Text で受け取る"),

  H.snip("bsToText", {
    imports = {
      H.imports.text,
      H.imports.text_encoding,
      H.imports.text_encoding_error,
      H.imports.bs,
    },
    def = {
      "-- 不正なバイト列は U+FFFD に置き換える（decodeUtf8 と違って例外を投げない）。",
      "bsToText :: BS.ByteString -> T.Text",
      "bsToText = TE.decodeUtf8With TEE.lenientDecode",
    },
  }, "Text: ByteString から Text へ（不正バイトで落ちない）"),

  H.snip("textToBS", {
    imports = { H.imports.text, H.imports.text_encoding, H.imports.bs },
    def = {
      "textToBS :: T.Text -> BS.ByteString",
      "textToBS = TE.encodeUtf8",
    },
  }, "Text: Text から ByteString へ（UTF-8）"),

  ---------------------------------------------------------------------------
  -- deriving 戦略（DerivingStrategies を一緒に連れてくる）
  ---------------------------------------------------------------------------
  H.snip("derivingStock", { pragmas = { DERIVING_STRATEGIES } }, "deriving: stock（GHC 組み込みの導出）", {
    t("deriving stock ("),
    i(1, "Show, Eq"),
    t(")"),
  }),

  H.snip("derivingNewtype", { pragmas = { DERIVING_STRATEGIES } }, "deriving: newtype（中身の実装をそのまま使う）", {
    t("deriving newtype ("),
    i(1, "Eq, Ord, Show"),
    t(")"),
  }),

  H.snip("derivingAnyclass", {
    pragmas = { DERIVING_STRATEGIES, "{-# LANGUAGE DeriveAnyClass #-}" },
  }, "deriving: anyclass（クラスの既定実装を使う）", {
    t("deriving anyclass ("),
    i(1, "ToJSON, FromJSON"),
    t(")"),
  }),

  H.snip("derivingVia", {
    pragmas = { DERIVING_STRATEGIES, "{-# LANGUAGE DerivingVia #-}" },
  }, "deriving: via（他の型の実装を借りる）", {
    t("deriving ("),
    i(1, "Semigroup, Monoid"),
    t(") via "),
    i(2, "Sum Int"),
  }),
}
