require("which-key").setup {
  triggers_blacklist = {
    n = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" },
    i = { "j", "k" },
    v = { "j", "k" },
  },
}
