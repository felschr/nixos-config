local wk = require("which-key")

wk.register({
  d = {
    name = "Debugging",
    c = { require"dap".continue, "Continue" },
    b = { require"dap".toggle_breakpoint, "Toggle breakpoint" },
    o = { require"dap".step_over, "Step over" },
    i = { require"dap".step_into, "Step into" },
    O = { require"dap".step_out, "Step out" },
    h = { require"dap".goto_, "Go to" },
    k = { require"dap.ui.widgets".hover, "Show info" },
    r = { require"dap".repl.open, "Open repl" },
    l = { require"dap".run_last, "Run last" },
  },
}, { mode = "n", prefix = "<leader>" })
