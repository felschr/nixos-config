require("neorg").setup {
  load = {
    ["core.defaults"] = {},
    ["core.norg.concealer"] = {},
    ["core.norg.completion"] = {
      config = {
        engine = "nvim-cmp",
      },
    },
    ["core.norg.dirman"] = {
      config = {
        workspaces = {
          work = "~/notes/work",
          home = "~/notes/home",
        },
      },
    },
    ["core.norg.qol.toc"] = {},
    ["core.gtd.base"] = {
      config = {
        workspace = "home",
      },
    },
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
