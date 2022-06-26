local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local keybind_opts = { noremap = true, silent = true, nowait = true }
local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {
  [[                               __                ]],
  [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
  [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
  [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
  [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
  [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
}
dashboard.section.buttons.val = {
  dashboard.button("p", " " .. " Find project", ":Telescope project display_type=full <CR>", keybind_opts),
  dashboard.button("s", " " .. " Restore session", ":RestoreSession <CR>", keybind_opts),
  dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>", keybind_opts),
  dashboard.button("e", " " .. " New file", ":ene <BAR> startinsert <CR>", keybind_opts),
  dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>", keybind_opts),
  dashboard.button("t", " " .. " Find text", ":Telescope live_grep <CR>", keybind_opts),
  dashboard.button("h", " " .. " Neovim Help", ":help<CR>", keybind_opts),
  dashboard.button("R", " " .. " Neovim Reference", ":help reference<CR>", keybind_opts),
  dashboard.button("q", " " .. " Quit", ":qa<CR>", keybind_opts),
}

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
alpha.setup(dashboard.opts)
