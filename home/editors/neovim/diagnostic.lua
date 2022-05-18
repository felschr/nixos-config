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

local wk = require("which-key")

wk.register({
  q = { vim.diagnostic.setloclist, "Show diagnostics in file" },
  i = {
    function()
      vim.diagnostic.open_float({ format = format })
    end,
    "Show diagnostics in line",
  },
}, { mode = "n", prefix = "<leader>" })

wk.register({
  ["[d"] = {
    function()
      vim.diagnostic.goto_prev({ format = format })
    end,
    "Go to next diagnostic",
  },
  ["]d"] = {
    function()
      vim.diagnostic.goto_next({ format = format })
    end,
    "Go to previous diagnostic",
  },
}, { mode = "n" })
