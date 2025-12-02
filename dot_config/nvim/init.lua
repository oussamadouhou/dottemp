-- Neovim configuration - managed by chezmoi
-- ~/.config/nvim/init.lua

-- Basic settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Show relative line numbers
vim.opt.mouse = 'a'              -- Enable mouse support
vim.opt.ignorecase = true        -- Case insensitive searching
vim.opt.smartcase = true         -- Case sensitive if uppercase present
vim.opt.hlsearch = false         -- Don't highlight searches
vim.opt.wrap = false             -- Don't wrap lines
vim.opt.breakindent = true       -- Preserve indentation in wrapped text
vim.opt.tabstop = 4              -- Number of spaces tabs count for
vim.opt.shiftwidth = 4           -- Size of an indent
vim.opt.expandtab = true         -- Use spaces instead of tabs
vim.opt.termguicolors = true     -- True color support
vim.opt.signcolumn = 'yes'       -- Always show sign column
vim.opt.updatetime = 250         -- Faster completion
vim.opt.timeoutlen = 300         -- Faster key sequence completion
vim.opt.clipboard = 'unnamedplus'-- Use system clipboard

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Key mappings
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>e', ':Ex<CR>', { desc = 'File explorer' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Move lines up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Auto-install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration
require('lazy').setup({
  -- Color scheme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('tokyonight-night')
    end,
  },

  -- File explorer
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup()
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
    end,
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find in files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
    end,
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
        },
      })
    end,
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end,
  },

  -- Auto pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- Commenting
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'lua', 'vim', 'vimdoc', 'python', 'javascript', 'typescript', 'rust', 'go' },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
})
