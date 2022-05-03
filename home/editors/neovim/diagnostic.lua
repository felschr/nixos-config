-- don't show underline & virtual_text for HINT severity
local min_info_severity = {
  min = vim.diagnostic.severity.INFO
}

local format = function(diagnostic)
  if diagnostic.code ~= nil then
    return string.format("%s [%s]", diagnostic.message, diagnostic.code)
  end
  return diagnostic.message
end

vim.diagnostic.config {
  severity_sort = true,
  underline = {
    severity = min_info_severity,
  },
  virtual_text = {
    severity = min_info_severity,
    format = format,
  },
  signs = true,
  float = true,
}

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { silent = true })
vim.keymap.set("n", "<leader>i", function()
  vim.diagnostic.open_float({ format = format })
end, { silent = true })
vim.keymap.set("n", "[d",        function()
  vim.diagnostic.goto_prev({ format = format })
end, { silent = true })
vim.keymap.set("n", "]d",        function()
  vim.diagnostic.goto_next({ format = format })
end, { silent = true })
vim.keymap.set("n", "[d",        vim.diagnostic.goto_prev, { silent = true })
vim.keymap.set("n", "]d",        vim.diagnostic.goto_next, { silent = true })
