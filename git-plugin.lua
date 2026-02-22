local vim = vim
local NS = { noremap = true, silent = true }

-- fugitive
local fugitive_augroup = vim.api.nvim_create_augroup("nvim_fugitive_end", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = fugitive_augroup,
  pattern = "fugitive",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<C-t>", ":lua vim.api.nvim_command('norm O')<cr>", NS)
    vim.api.nvim_buf_set_keymap(0, "n", "<C-l>", ":lua My_Open_Fugitive()<cr>", { noremap = true, silent = false })
    vim.api.nvim_buf_set_keymap(0, "n", "D", ":lua My_New_Gvsplit_Tab()<cr>", NS)
    vim.api.nvim_buf_set_keymap(0, "n", "<C-c>", ":q<CR>", NS)
  end,
})

function My_Open_Fugitive()
    vim.api.nvim_command('norm <cr>')
end

function My_New_Gvsplit_Tab()
  vim.api.nvim_command('norm O')
  vim.cmd('Gdiff')
end


return {
    -- figutive
    {
      'tpope/vim-fugitive',
      -- Usage:
      --   * reference other branch file in current branch.
      --       :Gvsplit origin/other_branch:filename.hoge
      --       :Gedit other_branch:%
      --   * cancel modification before commit.
      --       :Gread
      --   * git add
      --       :Gwrite
      -- Usage: 3-way diff :Gstatus -> D -> :diffget //2 |diffup -> :diffget //3 |diffup -> ]c -> :only
      -- Usage: recent master diff :Git fetch -> :Gvdiff -> origin/master

      -- " nnoremap gdb :Git difftool --name-status 
      -- vim.keymap.set('n', 'gdd', '<cmd>Gdiff', {noremap = true}),
      vim.keymap.set('n', 'gdb', '<cmd>Git difftool -y', {noremap = true}),
      vim.keymap.set('n', '<space>ge', '<cmd>Gvdiff %<left><left>', {noremap = true}),
      vim.keymap.set('n', 'gb', '<cmd>Git branch<cr>', NS),
      vim.keymap.set('n', '<space>gp', '<cmd>Gpull', {noremap = true}),
      vim.keymap.set('n', 'gss', '<cmd>Git<cr>', NS),
      vim.keymap.set('n', 'gco', '<cmd>Gcommit -m ""<left>', {noremap = true}),
      vim.keymap.set('n', 'gca', '<cmd>Gcommit -amend<cr>', NS),
      vim.keymap.set('n', 'gst', '<cmd>Git stash save ""<left>', {noremap = true}),
      vim.keymap.set('n', 'gsl', '<cmd>Git stash list<cr>', NS),
      vim.keymap.set('n', 'gsa', '<cmd>Git stash apply stash@{}<left>', {noremap = true}),
    },

    -- gitsigns
    {
      'lewis6991/gitsigns.nvim',
      config = function()
          require('gitsigns').setup{
              signs_staged_enable = false,
              signs = {
                  add = {text='+'},
                  change = {text = '~'},
                  delete = {text = '-'},
              },
              on_attach = function(bufnr)
                  local gitsigns = require('gitsigns')

                  local function map(mode, l, r, opts)
                      opts = opts or {}
                      opts.buffer = bufnr
                      vim.keymap.set(mode, l, r, opts)
                  end

                  map('n', ']g', function()
                    if vim.wo.diff then
                      vim.cmd.normal({']g', bang = true})
                    else
                      gitsigns.nav_hunk('next')
                    end
                  end)

                  map('n', '[g', function()
                    if vim.wo.diff then
                      vim.cmd.normal({'[g', bang = true})
                    else
                      gitsigns.nav_hunk('prev')
                    end
                  end)

                  map('n', '<space>gs', gitsigns.stage_hunk)
                  map('n', '<space>gu', gitsigns.reset_hunk)
                  -- map('n', '<space>gu', gitsigns.undo_stage_hunk)
                  map('v', '<space>gs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                  map('v', '<space>gu', gitsigns.undo_stage_hunk)
                  -- map('v', '<space>gu', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
                  map('n', '<space>gd', gitsigns.diffthis)
                  map('n', '<space>gD', function() gitsigns.diffthis('~') end)
                  map('n', '<space>gp', gitsigns.preview_hunk)
              end
          }
      end,
    },

    -- neogit
    {
        "NeogitOrg/neogit",
        lazy = true,
        dependencies = {
          "nvim-lua/plenary.nvim",         -- required
          "sindrets/diffview.nvim",        -- optional - Diff integration

          -- Only one of these is needed.
          "nvim-telescope/telescope.nvim", -- optional
          "ibhagwan/fzf-lua",              -- optional
          "nvim-mini/mini.pick",           -- optional
          "folke/snacks.nvim",             -- optional
        },
        cmd = "Neogit",
        keys = {
          { "gn", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
        },
        config = function()
            require('neogit').setup({})
        end,
    },
    {
        "sindrets/diffview.nvim",
         vim.keymap.set('n', 'gdo', '<cmd>DiffviewOpen<cr>', {noremap = true}),
         vim.keymap.set('n', 'gdd', '<cmd>DiffviewFileHistory<cr>', {noremap = true}),
         vim.keymap.set('n', 'gdh', '<cmd>DiffviewFileHistory %<cr>', {noremap = true}),
    },
}
