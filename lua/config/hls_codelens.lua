-- Haskell (HLS): 型シグネチャを行の上に仮想行で表示する codelens 機能（VSCode風）
-- lsp.lua の mason-lspconfig config から切り出した独立モジュール。M.setup() で LspAttach を登録する。

local M = {}

function M.setup()
  local hls_ns = vim.api.nvim_create_namespace("hls_type_sig")
  --- grl 後に Neovim 組み込みが nvim.lsp.codelens:* に同じレンズを描くため、二重・取り残しを消す。
  local function clear_hls_builtin_codelens_display(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    for _, cli in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "hls" })) do
      local builtin_ns = vim.api.nvim_create_namespace("nvim.lsp.codelens:" .. cli.id)
      vim.api.nvim_buf_clear_namespace(bufnr, builtin_ns, 0, -1)
    end
  end

  local hls_type_sig_debounce = {} --- @type table<integer, integer>

  local function show_hls_type_sigs(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    vim.lsp.buf_request(bufnr, "textDocument/codeLens", {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    }, function(err, result, ctx)
      if err or not result then return end
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      local c = vim.lsp.get_client_by_id(ctx.client_id)
      if not c or c.name ~= "hls" then return end

      clear_hls_builtin_codelens_display(bufnr)
      vim.api.nvim_buf_clear_namespace(bufnr, hls_ns, 0, -1)

      local client_id = ctx.client_id

      --- 表示用とは別に、vim.lsp.codelens.run() が使えるようキャッシュへ載せる。
      --- resolve 済み lens.command が result の各要素に入っている必要がある。
      local function finalize()
        vim.lsp.codelens.save(result, bufnr, client_id)
        clear_hls_builtin_codelens_display(bufnr)
        for _, ms in ipairs({ 80, 250, 500 }) do
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then clear_hls_builtin_codelens_display(bufnr) end
          end, ms)
        end
      end

      if #result == 0 then
        finalize()
        return
      end

      local pending = 0
      local has_line0 = false

      local function on_batch_done()
        if pending ~= 0 then return end
        finalize()
        if not has_line0 then return end
        vim.defer_fn(function()
          for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
            vim.api.nvim_win_call(win, function()
              vim.cmd("normal! \25") -- Ctrl-Y（1行目の仮想行があるときのみ）
            end)
          end
        end, 100)
      end

      local function place(line, title)
        if line == 0 then has_line0 = true end
        vim.api.nvim_buf_set_extmark(bufnr, hls_ns, line, 0, {
          virt_lines_above = true,
          virt_lines = { { { title, "LspCodeLens" } } },
        })
        pending = pending - 1
        on_batch_done()
      end

      for _, lens in ipairs(result) do
        pending = pending + 1
        if lens.command then
          place(lens.range.start.line, lens.command.title)
        else
          c:request("codeLens/resolve", lens, function(rerr, resolved)
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if rerr or not resolved or not resolved.command then
              pending = pending - 1
              on_batch_done()
              return
            end
            lens.command = resolved.command
            if resolved.range then
              lens.range = resolved.range
            end
            place(lens.range.start.line, lens.command.title)
          end, bufnr)
        end
      end
    end)
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local c = vim.lsp.get_client_by_id(args.data.client_id)
      if not c or c.name ~= "hls" then return end
      local bufnr = args.buf

      local function debounced_show()
        local tick = (hls_type_sig_debounce[bufnr] or 0) + 1
        hls_type_sig_debounce[bufnr] = tick
        vim.defer_fn(function()
          if hls_type_sig_debounce[bufnr] ~= tick then return end
          show_hls_type_sigs(bufnr)
        end, 380)
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        buffer = bufnr,
        callback = function() show_hls_type_sigs(bufnr) end,
      })
      -- grl や LSP のテキスト編集では InsertLeave が来ないことがある → 仮想行が古いまま残る
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = bufnr,
        callback = debounced_show,
      })
      vim.api.nvim_create_autocmd("BufUnload", {
        buffer = bufnr,
        callback = function(ev) hls_type_sig_debounce[ev.buf] = nil end,
      })
      vim.defer_fn(function() show_hls_type_sigs(bufnr) end, 3000)
    end,
  })
end

return M
