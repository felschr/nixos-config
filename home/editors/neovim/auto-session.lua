vim.o.sessionoptions = "buffers,curdir,tabpages,winsize"

require("auto-session").setup {
  auto_session_suppress_dirs = { "~/", "~/dev", "~/dev/work" },
  auto_session_enabled = false,
  pre_save_cmds = { "tabdo NvimTreeClose" },
}

local wk = require("which-key")
wk.register({
  S = {
    name = "Session",
    d = { require("auto-session").DeleteSession, "Delete session" },
    s = { require("auto-session").SaveSession, "Save session" },
    r = { require("auto-session").RestoreSession, "Restore session" },
  },
}, { mode = "n", prefix = "<leader>" })
