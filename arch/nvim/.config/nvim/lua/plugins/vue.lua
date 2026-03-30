-- Override gd on Vue files to request definitions only from vtsls.
-- Volar never responds to textDocument/definition in the <script>
-- section, causing NeoVim to hang waiting for all clients.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    if vim.bo[event.buf].filetype ~= "vue" then
      return
    end

    -- Use vim.schedule to run after all other LspAttach handlers
    vim.schedule(function()
      vim.keymap.set("n", "gd", function()
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })
        if #clients == 0 then
          vim.lsp.buf.definition()
          return
        end

        local client = clients[1]
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        client:request("textDocument/definition", params, function(err, result, ctx)
          if err or not result or vim.tbl_isempty(result) then
            return
          end
          vim.schedule(function()
            -- Filter out self-referencing results (same file and position)
            local cursor_line = params.position.line
            local buf_uri = params.textDocument.uri
            local filtered = vim.tbl_filter(function(loc)
              local uri = loc.targetUri or loc.uri
              local range = loc.targetSelectionRange or loc.range
              if uri ~= buf_uri then
                return true
              end
              return range.start.line ~= cursor_line
            end, result)

            if #filtered == 0 then
              filtered = result
            end

            if #filtered == 1 then
              vim.lsp.util.show_document(filtered[1], client.offset_encoding, { focus = true })
            else
              vim.fn.setqflist({}, " ", {
                title = "LSP Definitions",
                items = vim.lsp.util.locations_to_items(filtered, client.offset_encoding),
              })
              vim.cmd("cfirst")
            end
          end)
        end, 0)
      end, { buffer = event.buf, desc = "Goto Definition" })
    end)
  end,
})

return {}
