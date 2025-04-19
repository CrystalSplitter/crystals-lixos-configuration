return {
  {
    'srcery-colors/srcery-vim',
    lazy = false,
    priority = 1000, -- Load this first
    config = function()
      -- Actually ensure that the colours are
      -- correct here.
      if vim.fn.has('termguicolors') then
        vim.opt.termguicolors = true
      end
      vim.cmd('colorscheme srcery')
    end
  },
  -- {
  --   'sainnhe/everforest',
  --   lazy = false,
  --   priority = 1000, -- Load this first
  --   config = function()
  --     -- Actually ensure that the colours are
  --     -- correct here.
  --     if vim.fn.has('termguicolors') then
  --       vim.opt.termguicolors = true
  --     end
  --     vim.cmd('colorscheme everforest')
  --   end
  -- },
  {
    'flazz/vim-colorschemes',
    lazy = true,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>ne', ':Neotree<CR>')
    end
  },
  {
    'tpope/vim-fugitive',
    cmd = {
      "G",
      "Git",
      "Gllog",
      "GDiff",
      "Gclog",
    },
    lazy = true,
  },
  {
    'udalov/kotlin-vim',
    lazy = true,
    ft = {'kotlin', 'kt', 'kt'},
  },
  {
    'rhysd/vim-wasm',
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      require'lspconfig'.kotlin_language_server.setup{}
      require'lspconfig'.pyright.setup{}
      require'lspconfig'.hls.setup{}
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
    end
  },
  {
    'github/copilot.vim',
    lazy = false,
  }
}
