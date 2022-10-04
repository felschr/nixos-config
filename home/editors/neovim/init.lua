-- vim.opt.shell = "/bin/sh"

vim.opt.title = true
vim.opt.titlestring = "%t - nvim"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.timeoutlen = 500

-- reduce CursorHold delay
vim.opt.updatetime = 500

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.camelcasemotion_key = "<leader>"

vim.opt.relativenumber = true
vim.opt.splitbelow = true

vim.g.nvcode_termcolors = 256
vim.cmd("syntax on")
vim.cmd("colorscheme nvcode")
vim.cmd("hi TSCurrentScope guifg=NONE ctermfg=NONE guibg=#252526 ctermbg=235 gui=NONE cterm=NONE")

-- vim-closetag
vim.g.closetag_filenames = "*.html,*.jsx,*.tsx,*.vue,*.xhml,*.xml"
vim.g.closetag_regions = {
  ["typescript.tsx"] = "jsxRegion,tsxRegion",
  ["javascript.jsx"] = "jsxRegion",
}

local wk = require("which-key")

require("nvim-tree").setup {}
wk.register({
  ["<C-p>"] = { require("nvim-tree").toggle, "Toggle NVimTree" },
}, { mode = "n" })

require("toggleterm").setup {
  open_mapping = "<A-t>",
  size = 16,
}

require("neogit").setup {}
