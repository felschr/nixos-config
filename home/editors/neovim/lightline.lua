function LspStatus()
  local sl = ""
  if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    if (errors > 0 or warnings > 0 or infos > 0 or hints > 0) then
      if errors > 0 then
        sl = sl .. " " .. errors
      end
      if warnings > 0 then
        sl = sl .. "  " .. warnings
      end
      if infos > 0 then
        sl = sl .. "  " .. infos
      end
      if hints > 0 then
        sl = sl .. "  " .. hints
      end
    else
      sl = sl .. ""
    end
  end
  return sl
end

function GitStatus()
  local status = vim.b.gitsigns_status
  return status ~= nil and status or ""
end

vim.g.lightline = {
  colorscheme = "powerline",
  active = {
    left = {
      { "mode", "paste" },
      { "lspstatus", "readonly", "filename", "gitstatus", "modified" },
    },
  },
  component_expand = {
    lspstatus = "{ -> luaeval('LspStatus()')}",
    gitstatus = "{ -> luaeval('GitStatus()')}",
  },
}

-- update on lsp status changes
vim.cmd([[
  augroup lightline_diagnostics
    autocmd!
    autocmd User LspProgressUpdate call lightline#update()
    autocmd DiagnosticChanged * call lightline#update()
  augroup END
]])
