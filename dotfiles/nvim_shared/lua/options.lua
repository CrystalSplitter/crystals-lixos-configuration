vim.o.termguicolors = true
vim.g.sonokai_style = 'atlantis'
vim.cmd.colorscheme('sonokai')

require('lualine').setup {
  options = {
    theme = 'sonokai'
  }
}

-- --- Remappings and keybinds ---
local keycode = vim.keycode
vim.g.mapleader = keycode','

-- Neotree
vim.keymap.set('n', '<Leader>|', '<cmd>Neotree left reveal<cr>')
vim.keymap.set('n', '<Leader>b', '<cmd>Neotree toggle show buffers right<cr>')

-- Nvim LSP
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.lsp.config('ts_ls', {
    on_attach = function(client, bufnr)
	vim.lsp.completion.enable(true, client.id, bufnr, {
		autotrigger = true,
		convert = function(item)
		return { abbr = item.label:gsub("%b()", "") }
		end,
	})
	vim.keymap.set("i", "<C-space>", vim.lsp.completion.get,
	  { desc = "trigger autocompletion" }
        )
    end
})

-- --- Generic ---
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.signcolumn = 'yes'
vim.opt.number = true
