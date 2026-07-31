-- Haskell スニペットの共通機構。スニペット本体は snippets/lua/haskell/*.lua にある。
--
-- 方針: 呼び出し側だけをカーソル位置に挿入し、足りないものを自動で補う。
--   ・定義       -> ファイル末尾
--   ・import     -> 既存の import 群の直後
--   ・LANGUAGE   -> 先頭コメント（タイトル・URL・メモ）の直後
--
--   main = do
--     as <- getInts      <- "getInts" を補完するとここに名前が入り、
--                           同時に下へ定義（ints / readInt も）、上へ import が生える
--
-- import を面倒みるので、テンプレート（template/Main.hs）は main の 2 行だけで済む。
-- ByteString を使わない問題に ByteString の import が残らない。
--
-- deps で「この定義が使っている別スニペット」を宣言する。展開時に依存を辿って一緒に
-- 生やすので、共通処理（readInt など）を where に閉じ込めてコピーせずに済み、
-- 生えるコードも普通の Haskell の書き方になる。同じ定義は 2 度生えない。

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local events = require("luasnip.util.events")

local M = {}

-- トリガ名 -> spec { def, imports, pragmas, deps }
M.specs = {}

-- qualified import の正規表記。別名（BS / T / M など）が定義側とスニペット側でずれると
-- 生えたコードがコンパイルできなくなるので、ここを唯一の出どころにする。
-- 名前リスト付きの import（`import Data.List (sort)` 等）は、定義が実際に使うものだけを
-- 各スニペット側に書く（-Wall で未使用 import の警告を出さないため）。
M.imports = {
  bs = "import qualified Data.ByteString.Char8 as BS",
  builder = "import qualified Data.ByteString.Builder as BSB",
  text = "import qualified Data.Text as T",
  text_io = "import qualified Data.Text.IO as TIO",
  text_encoding = "import qualified Data.Text.Encoding as TE",
  text_encoding_error = "import qualified Data.Text.Encoding.Error as TEE",
  map = "import qualified Data.Map.Strict as M",
  intmap = "import qualified Data.IntMap.Strict as IM",
  set = "import qualified Data.Set as S",
  intset = "import qualified Data.IntSet as IS",
  vector = "import qualified Data.Vector.Unboxed as VU",
  vector_mut = "import qualified Data.Vector.Unboxed.Mutable as VUM",
}

---------------------------------------------------------------------------
-- 既に書かれているかの判定
---------------------------------------------------------------------------

-- トップレベル定義は必ず 1 桁目から始まるので、行頭に固定して見る。
-- 部分一致（"putInts ::" が "ints ::" を含む）で取りこぼさないため。
--
-- 型シグネチャ（readInt ::）だけでなく束縛（readInt = / readInt bs = ...）も見る。
-- 生やす定義には必ずシグネチャが付くが、ユーザーが自分で書いた同名の定義には
-- 付いていないことがあり、そこへ重ねて生やすと二重定義になる。
--
-- 束縛は "=" のある行に限る。行頭でスニペットを展開した直後はカーソル行が
-- トリガ名（"getInts"）で始まっており、それを既存の定義と取り違えないため。
local function defined(lines, name)
  local sig = "^" .. vim.pesc(name) .. "%s*::"
  local bind = "^" .. vim.pesc(name) .. "%f[^%w'_].*="
  for _, l in ipairs(lines) do
    if l:match(sig) or l:match(bind) then
      return true
    end
  end
  return false
end

-- 同じ拡張が別の LANGUAGE 行（`{-# LANGUAGE Foo, Bar #-}` など）で有効化済みなら足さない。
local function pragma_present(lines, pragma)
  local ext = pragma:match("LANGUAGE%s+([%w_]+)")
  if not ext then
    return vim.tbl_contains(lines, pragma)
  end
  for _, l in ipairs(lines) do
    if l:match("^{%-#%s*LANGUAGE") and l:match("%f[%w]" .. ext .. "%f[%W]") then
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------
-- import 行の統合
---------------------------------------------------------------------------

-- `import Data.List (sort, foldl')` 形式なら モジュール名と名前リストを返す。
-- qualified import はここでは扱わず、行の完全一致で重複を見る。
local function parse_import(line)
  return line:match("^import%s+([%w%.]+)%s*%((.*)%)%s*$")
end

local function split_names(str)
  local out = {}
  for name in str:gmatch("[^,]+") do
    table.insert(out, vim.trim(name))
  end
  return out
end

local function render_import(mod, names)
  return ("import %s (%s)"):format(mod, table.concat(names, ", "))
end

-- 複数の spec が同じモジュールを要求したとき（Data.List を 2 つの定義が使う等）に
-- 1 行へまとめる。qualified import など解析できない行は重複だけ落とす。
local function normalize(imports)
  local entries, by_mod, seen = {}, {}, {}
  for _, imp in ipairs(imports) do
    local mod, names = parse_import(imp)
    if mod then
      local entry = by_mod[mod]
      if not entry then
        entry = { mod = mod, names = {}, have = {} }
        by_mod[mod] = entry
        table.insert(entries, entry)
      end
      for _, name in ipairs(split_names(names)) do
        if not entry.have[name] then
          entry.have[name] = true
          table.insert(entry.names, name)
        end
      end
    elseif not seen[imp] then
      seen[imp] = true
      table.insert(entries, { line = imp })
    end
  end

  local out = {}
  for _, entry in ipairs(entries) do
    table.insert(out, entry.line or render_import(entry.mod, entry.names))
  end
  return out
end

-- 既に同じモジュールの import 行があれば、そこへ名前を足して true を返す。
-- （`import Data.List (sort)` の下にもう 1 行 Data.List を並べない）
local function merge_into_existing(buf, lines, imp)
  local mod, names = parse_import(imp)
  if not mod then
    return false
  end
  for idx, l in ipairs(lines) do
    local l_mod, l_names = parse_import(l)
    if l_mod == mod then
      local merged, have = split_names(l_names), {}
      for _, name in ipairs(merged) do
        have[name] = true
      end
      local added = false
      for _, name in ipairs(split_names(names)) do
        if not have[name] then
          have[name] = true
          added = true
          table.insert(merged, name)
        end
      end
      if added then
        lines[idx] = render_import(mod, merged)
        vim.api.nvim_buf_set_lines(buf, idx - 1, idx, false, { lines[idx] })
      end
      return true
    end
  end
  return false
end

---------------------------------------------------------------------------
-- 先頭側（pragma / import）へ足す
---------------------------------------------------------------------------

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

-- 先頭に並んでいる pragma の最後の行。既にある pragma のすぐ下へ足したいので使う。
-- module 宣言や import が出てきたら打ち切る（関数に付いた {-# INLINE #-} を拾わない）。
local function pragma_end(lines, from)
  local at = from
  for idx, l in ipairs(lines) do
    if l:match("^{%-#%s*LANGUAGE") or l:match("^{%-#%s*OPTIONS") then
      at = idx
    elseif not (l:match("^%s*%-%-") or l:match("^%s*$")) then
      break
    end
  end
  return at
end

-- import の入れ先。既存 import の直後 > module 宣言（の where）の直後 > pragma の直後。
local function import_end(lines, fallback)
  local at = fallback
  for idx, l in ipairs(lines) do
    if l:match("^module%s") then
      at = idx
      -- export リストが複数行にわたることがあるので where のある行まで送る
      for j = idx, #lines do
        if lines[j]:match("%f[%w]where%f[%W]") then
          at = j
          break
        end
      end
      break
    end
  end
  for idx, l in ipairs(lines) do
    if l:match("^import ") then
      at = idx
    end
  end
  return at
end

-- pragma と import のうち、まだ無いものだけを先頭側へ足す。
local function ensure_header(buf, want)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local pragmas = {}
  for _, pragma in ipairs(want.pragmas) do
    if not pragma_present(lines, pragma) then
      table.insert(pragmas, pragma)
    end
  end

  local imports = {}
  for _, imp in ipairs(normalize(want.imports)) do
    -- 既存行へ統合できたものはここで片付く。残りだけを新しい行として足す。
    if not merge_into_existing(buf, lines, imp) and not vim.tbl_contains(lines, imp) then
      table.insert(imports, imp)
    end
  end

  if #pragmas == 0 and #imports == 0 then
    return
  end

  -- pragma は先頭コメントの直後、既に pragma があるならその並びの末尾へ。
  local top = pragma_end(lines, header_end(lines))
  -- import は既存 import / module 宣言の直後へ。どちらも無ければ pragma と同じ位置に
  -- 置き、あとから pragma をその上に差し込む（結果は pragma -> import の順）。
  local at = import_end(lines, top)

  -- 行番号がずれないよう、下（import）から先に入れる。
  if #imports > 0 then
    local block = vim.deepcopy(imports)
    -- pragma / module 宣言の直後なら 1 行あける（import の並びの中なら詰める）
    if lines[at] and lines[at] ~= "" and not lines[at]:match("^import ") then
      table.insert(block, 1, "")
    end
    local following = lines[at + 1]
    if following and not following:match("^%s*$") then
      table.insert(block, "")
    end
    vim.api.nvim_buf_set_lines(buf, at, at, false, block)
  end
  if #pragmas > 0 then
    local block = vim.deepcopy(pragmas)
    -- 直後が既に空行（or ファイル末尾）なら空行を重ねない
    local following = lines[top + 1]
    if following and not following:match("^%s*$") then
      table.insert(block, "")
    end
    vim.api.nvim_buf_set_lines(buf, top, top, false, block)
  end
end

---------------------------------------------------------------------------
-- 依存を辿って足す
---------------------------------------------------------------------------

-- 依存先を先に集める（ファイル末尾では readInt -> ints -> getInts の順に並ぶ）。
local function collect(name, seen, want)
  if seen[name] then
    return
  end
  seen[name] = true
  local spec = M.specs[name]
  if not spec then
    return
  end
  for _, dep in ipairs(spec.deps or {}) do
    collect(dep, seen, want)
  end
  vim.list_extend(want.pragmas, spec.pragmas or {})
  vim.list_extend(want.imports, spec.imports or {})
  if spec.def then
    table.insert(want.defs, { name = name, lines = spec.def })
  end
end

-- 足りないものをバッファに書き足す。
-- 展開の最中にバッファを触ると LuaSnip の位置追跡が壊れるので vim.schedule で遅らせる。
local function grow(name)
  vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    local want = { pragmas = {}, imports = {}, defs = {} }
    collect(name, {}, want)
    ensure_header(buf, want)

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local add = {}
    for _, def in ipairs(want.defs) do
      if not defined(lines, def.name) then
        table.insert(add, "")
        vim.list_extend(add, def.lines)
        vim.list_extend(lines, def.lines) -- 同じ展開の中でも二重に足さない
      end
    end
    if #add > 0 then
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, add)
    end
  end)
end

---------------------------------------------------------------------------
-- スニペットの作り方
---------------------------------------------------------------------------

--- name を打つと nodes が入り、spec の中身（定義・import・pragma）が足される。
---
--- 副作用は必ず snippet の enter イベント（＝実際に展開された瞬間）で起こす。
--- function_node に載せてはいけない: LuaSnip は docstring を作るときにノードを
--- 静的評価するため、blink.cmp が補完候補のドキュメントを出しただけで
--- （Enter で確定していないのに）定義と import がバッファに生えてしまう。
--- enter は再ジャンプで複数回呼ばれうるが、grow は重複チェック済みで冪等。
---@param name string トリガ。nodes 省略時はこの文字列がそのまま挿入される
---@param spec table { def, imports, pragmas, deps }
---@param desc string 補完候補に出る説明
---@param nodes table? カーソル位置に入れるノード
function M.snip(name, spec, desc, nodes)
  M.specs[name] = spec
  return s({ trig = name, desc = desc }, nodes or { t(name) }, {
    callbacks = {
      [-1] = {
        [events.enter] = function()
          grow(name)
        end,
      },
    },
  })
end

--- pragma / import を足すだけのスニペット。カーソル位置には何も残らない
--- （pragma はファイル先頭、import は import 群の末尾という正しい場所へ生える）。
function M.header(name, spec, desc)
  return M.snip(name, spec, desc, { t("") })
end

return M
