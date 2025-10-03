------------------MAPPTINGS------------------

local utils = require("marcos.utils")

local keymap = vim.keymap.set

-- Set leader

vim.g.mapleader = " "

-- Chg to current file directory
keymap("n", "<leader>cd", "<CMD>lcd %:p:h<CR>")

-- Move selected line / block of text in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Better navigation

keymap("n", "J", "mzJ`z")
keymap("n", "<C-d>", "<cmd>normal! <C-d>zz<CR>")
keymap("n", "<C-u>", "<cmd>normal! <C-u>zz<CR>")
keymap("n", "n", "<cmd>normal! nzz<CR>")
keymap("n", "N", "<cmd>normal! Nzz<CR>")
keymap("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Tab management.
keymap("n", "<leader>tc", "<cmd>tabclose<cr>", { desc = "Close tab page" })
keymap("n", "<leader>tn", "<cmd>tab split<cr>", { desc = "New tab page" })
keymap("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tab pages" })

-- Error navigation
-- Go to previous/next error
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous Error" })

vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next Error" })

-- Go to previous/next warning
vim.keymap.set("n", "[w", function()
	vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Previous Warning" })

vim.keymap.set("n", "]w", function()
	vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
end, { desc = "Next Warning" })

-- Execute macro over a visual region.
keymap("x", "@", function()
	return ":norm @" .. vim.fn.getcharstr() .. "<cr>"
end, { expr = true })

-- greatest remap ever
keymap("x", "<leader>p", [["_dP]])

-- Terminal Escape
local opts = {}
keymap("t", "jk", [[<C-\><C-n>]], opts)

-- Indent while remaining in visual mode.
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- run current file
keymap("n", "<leader>rr", utils.save_and_exec, { desc = "Save and execute file" })

-- next greatest remap ever : asbjornHaland
keymap({ "n", "v" }, "<leader>y", [["+y]])
keymap("n", "<leader>Y", [["+Y]])

keymap({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

keymap("n", "<leader>sR", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace under the cursor" })

-- keymap("n", "<leader>za", utils.simple_fold, { desc = "Fold function" })

-- grant execute permission
keymap("n", "<leader>xe", "<cmd>!chmod +x %<CR>", { silent = true })

keymap("n", "<leader>vpp", "<cmd>e ~/.dotfiles/.config/nvim/lua/marcos/plugins<CR>")

-- source file
keymap("n", "<leader><leader>", function()
	vim.cmd("so")
end)

-- tmux sessionizer
keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Lazy window
keymap("n", "<leader>l", function()
	vim.cmd("Lazy")
end)

-- Lsp Formatting
keymap("n", "<leader>f", vim.lsp.buf.format)

-- Quickfix navigation
keymap("n", "<C-j>", "<cmd>cnext<CR>zz")
keymap("n", "<C-k>", "<cmd>cprev<CR>zz")
keymap("n", "<leader>j", "<cmd>lnext<CR>zz")
keymap("n", "<leader>k", "<cmd>lprev<CR>zz")
