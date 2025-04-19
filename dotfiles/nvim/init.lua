-- Module loading
-- Some settings are configured in config.lazy,
-- and some are in the plugins themselves.
require('config.lazy')

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Set line numbers
vim.opt.number = true
-- vim.opt.relativenumber = true

-- Always display the signcolumn (gutter)
vim.opt.signcolumn = 'yes'
