require("neorg").setup {
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.completion"] = {
      config = {
        engine = "nvim-cmp",
      },
    },
    ["core.dirman"] = {
      config = {
        workspaces = {
          work = "~/notes/work",
          home = "~/notes/home",
        },
      },
    },
    ["core.qol.toc"] = {},
  },
}

vim.opt.conceallevel = 2

local wk = require("which-key")
wk.register({
  name = "Neorg To-do actions",
  u = "Undone",
  p = "Pending",
  d = "Done",
  h = "On Hold",
  c = "Cancelled",
  i = "Important",
}, { mode = "n", prefix = "gt" })

wk.register({
  m = {
    name = "Neorg mode",
    n = "norg",
    h = "traverse-heading",
  },
  n = {
    name = "Neorg dirman",
    n = "New note",
  },
  t = {
    name = "Neorg GTD",
    c = "Capture",
    e = "Edit",
    v = "Views",
  },
}, { mode = "n", prefix = "<localleader>" })
