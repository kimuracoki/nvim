return {
  -- Ctrl-a / Ctrl-x の増減を拡張（VSCode には無い Vim ならではの強化）。
  -- 数値だけでなく 日付・true/false・&&//|| などトグル可能な語を、カーソル位置に応じて増減する。
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>",  function() require("dial.map").manipulate("increment", "normal") end,  mode = "n", desc = "Dial: Increment (増加)" },
      { "<C-x>",  function() require("dial.map").manipulate("decrement", "normal") end,  mode = "n", desc = "Dial: Decrement (減少)" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n", desc = "Dial: Increment 累積 (連番)" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n", desc = "Dial: Decrement 累積 (連番)" },
      { "<C-a>",  function() require("dial.map").manipulate("increment", "visual") end,  mode = "v", desc = "Dial: Increment (選択)" },
      { "<C-x>",  function() require("dial.map").manipulate("decrement", "visual") end,  mode = "v", desc = "Dial: Decrement (選択)" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "Dial: Increment 連番 (選択)" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "Dial: Decrement 連番 (選択)" },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,             -- 10進数（負数も）
          augend.integer.alias.hex,                 -- 16進数 0xff
          augend.date.alias["%Y/%m/%d"],            -- 2026/07/28
          augend.date.alias["%Y-%m-%d"],            -- 2026-07-28
          augend.date.alias["%H:%M"],               -- 時刻
          augend.constant.alias.bool,               -- true <-> false
          augend.semver.alias.semver,               -- 1.2.3 のバージョン
          augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "yes", "no" }, word = true, cyclic = true }),
        },
      })
    end,
  },
}
