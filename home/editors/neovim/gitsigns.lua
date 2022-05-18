local wk = require("which-key")

require("gitsigns").setup {
  on_attach = function(bufnr)
    -- Navigation
    wk.register({
      ["]c"] = { "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", "Go to next git sign" },
      ["[c"] = { "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", "Go to previous git sign" },
    }, { mode = "n", buffer = bufnr })

    -- Actions
    wk.register({
      h = {
        name = "Git signs",
        s = { ":Gitsigns stage_hunk<CR>", "Stage hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "Reset hunk" },
        S = { "<cmd>Gitsigns stage_buffer<CR>", "Stage buffer" },
        u = { "<cmd>Gitsigns undo_stage_hunk<CR>", "Unstage hunk" },
        R = { "<cmd>Gitsigns reset_buffer<CR>", "Reset buffer" },
        p = { "<cmd>Gitsigns preview_hunk<CR>", "Preview hunk" },
        b = { require"gitsigns".blame_line({ full = true }), "Blame line" },
        d = { "<cmd>Gitsigns diffthis<CR>", "Diff" },
        D = { require"gitsigns".diffthis('~'), "Diff" },
      },
      t = {
        name = "Git sign toggles",
        b = { "<cmd>Gitsigns toggle_current_line_blame<CR>", "Toggle current line" },
        d = { "<cmd>Gitsigns toggle_deleted<CR>", "Toggle deleted" },
      },
    }, { mode = "n", prefix = "<leader>", buffer = bufnr })
    wk.register({
      h = {
        name = "Git signs",
        s = { ":Gitsigns stage_hunk<CR>", "Stage hunk" },
        r = { ":Gitsigns reset_hunk<CR>", "Reset hunk" },
      },
    }, { mode = "v", prefix = "<leader>", buffer = bufnr })

    -- Text object
    wk.register({
      ih = { ":<C-U>Gitsigns select_hunk<CR>", "Select hunk", mode = "o" },
      oh = { ":<C-U>Gitsigns select_hunk<CR>", "Select hunk", mode = "x" },
    }, { buffer = bufnr })
  end
}
