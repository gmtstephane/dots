require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "CMD enter command mode" })
map("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "CMD enter command mode" })
map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "CMD enter command mode" })
map("n", "gs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "CMD enter command mode" })
map("n", "<leader>tt", "<cmd>lua require('base46').toggle_theme()<CR>", { desc = "CMD enter command mode" })
map("n", "<leader>ds", function()
  require("scripts.go.struct_copy").generate_and_copy_to_register "*"
end, { desc = "CMD enter command mode" })
