require("telescope").setup {
  extensions = {
    project = {
      base_dirs = {
        { "/etc/nixos" },
        { "~/dev", max_depth = 3 },
        { "~/dev/work", max_depth = 3 },
      },
    },
  },
}

require("telescope").load_extension("fzy_native")
require("telescope").load_extension("project")

local wk = require("which-key")

wk.register({
  [";"] = { require("telescope.builtin").find_files, "Find files" },
  [","] = { require("telescope.builtin").live_grep, "Live grep" },
}, { mode = "n" })

wk.register({
  t = {
    name = "Telescope",
    a = { require("telescope.builtin").autocommands, "Autocommands" },
    b = { require("telescope.builtin").current_buffer_fuzzy_find, "Current buffer" },
    B = { require("telescope.builtin").buffers, "Buffers" },
    c = { require("telescope.builtin").live_grep, "Live grep" },
    C = { require("telescope.builtin").commands, "Commands" },
    f = { require("telescope.builtin").find_files, "Files" },
    g = {
      name = "Git",
      b = { require("telescope.builtin").git_branches, "Branches" },
      c = { require("telescope.builtin").git_bcommits, "Commits in buffer" },
      C = { require("telescope.builtin").git_commits, "Commits" },
      f = { require("telescope.builtin").git_files, "Files" },
      s = { require("telescope.builtin").git_statu, "Status" },
      S = { require("telescope.builtin").git_stash, "Stash" },
    },
    h = { require("telescope.builtin").search_history, "Search history" },
    H = { require("telescope.builtin").command_history, "Command history" },
    j = { require("telescope.builtin").jumplist, "Jump List" },
    l = {
      name = "LSP",
      d = { require("telescope.builtin").lsp_definitions, "Definitions" },
      D = { require("telescope.builtin").diagnostics, "Diagnostics" },
      i = { require("telescope.builtin").lsp_implementations, "Implementations" },
      r = { require("telescope.builtin").lsp_references, "References" },
      s = { require("telescope.builtin").lsp_document_symbols, "Document symbols" },
      S = { require("telescope.builtin").lsp_workspace_symbols, "Workspace symbols" },
      y = { require("telescope.builtin").lsp_type_definitions, "Type definitions" },
    },
    L = { require("telescope.builtin").loclist, "Location list" },
    m = { require("telescope.builtin").marks, "Marks" },
    M = { require("telescope.builtin").man_pages, "Man pages" },
    o = { require("telescope.builtin").oldfiles, "Previously open files" },
    p = { require("telescope").extensions.project.project, "Pickers" },
    P = { require("telescope.builtin").pickers, "Pickers" },
    q = { require("telescope.builtin").quickfix, "Quickfix" },
    Q = { require("telescope.builtin").quickfixhistory, "Quickfix history" },
    r = { require("telescope.builtin").resume, "Resume" },
    R = { require("telescope.builtin").registers, "Registers" },
    s = { require("telescope.builtin").grep_string, "Grep string under cursor" },
    t = { require("telescope.builtin").tags, "Tags" },
    T = { require("telescope.builtin").current_buffer_tags, "Tags in current buffer" },
    v = { require("telescope.builtin").vim_options, "Vim options" },
    x = {
      name = "More",
      h = { require("telescope.builtin").highlights, "Highlights" },
      H = { require("telescope.builtin").help_tags, "Help tags" },
      t = { require("telescope.builtin").treesitter, "Treesitter" },
    },
  },
}, { mode = "n", prefix = "<leader>" })
