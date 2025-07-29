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
keymap(
	"n",
	"<C-d>",
	"<cmd>lua vim.cmd('normal! <C-d>'); require('mini.animate').execute_after('scroll', 'normal! zz')<cr>"
)
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
keymap(
	"n",
	"<C-u>",
	"<cmd>lua vim.cmd('normal! <C-u>'); require('mini.animate').execute_after('scroll', 'normal! zz')<cr>"
)
keymap("n", "n", "<cmd>lua vim.cmd('normal! n'); require('mini.animate').execute_after('scroll', 'normal! zvzz')<cr>")
keymap("n", "N", "<cmd>lua vim.cmd('normal! N'); require('mini.animate').execute_after('scroll', 'normal! zvzz')<cr>")

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
keymap("n", "<leader>r", utils.save_and_exec, { desc = "Save and execute file" })

-- next greatest remap ever : asbjornHaland
keymap({ "n", "v" }, "<leader>y", [["+y]])
keymap("n", "<leader>Y", [["+Y]])

-- delete to black hole register
keymap({ "n", "v" }, "<leader>d", [["_d]])

-- replace word under cursor
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

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
-- keymap("n", "<C-j>", "<cmd>cnext<CR>zz")
-- keymap("n", "<C-k>", "<cmd>cprev<CR>zz")
keymap("n", "<leader>j", "<cmd>lnext<CR>zz")
keymap("n", "<leader>k", "<cmd>lprev<CR>zz")
