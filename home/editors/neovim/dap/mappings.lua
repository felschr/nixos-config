local map = vim.api.nvim_set_keymap

map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>", { noremap = true })
map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true })
map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<CR>", { noremap = true })
map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<CR>", { noremap = true })
map("n", "<leader>dO", "<cmd>lua require'dap'.step_out()<CR>", { noremap = true })
map("n", "<leader>dh", "<cmd>lua require'dap'.goto()<CR>", { noremap = true })
map("n", "<leader>dk", "<cmd>lua require'dap.ui.variables'.hover()<CR>", { noremap = true })
map("n", "<leader>dr", "<cmd>lua require'dap'.repl.open()<CR>", { noremap = true })
map("n", "<leader>dl", "<cmd>lua require'dap'.repl.run_last()<CR>", { noremap = true })
