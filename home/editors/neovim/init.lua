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
vim.g.maplocalleader = ","
vim.g.camelcasemotion_key = "<leader>"

vim.opt.relativenumber = true
vim.opt.splitbelow = true

-- opt-in to filetype.lua
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

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

vim.keymap.set("n", ";", require("telescope.builtin").find_files)
vim.keymap.set("n", ",", require("telescope.builtin").live_grep)

require("nvim-tree").setup {}
vim.keymap.set("n", "<C-p>", require("nvim-tree").toggle)

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 20

require("toggleterm").setup {
  open_mapping = "<A-t>",
  size = 16,
}

require("neogit").setup {}
