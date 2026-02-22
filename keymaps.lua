-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


local opts = { noremap = true, silent = true }
-- local term_opts = { silent = true }

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

vim.api.nvim_create_user_command('VI', ':tab drop ~/.config/nvim/init.lua', {})
vim.api.nvim_create_user_command('KM', ':tab drop ~/.config/nvim/lua/keymaps.lua', {})
vim.api.nvim_create_user_command('DE', ':tab drop ~/.config/nvim/lua/plugins/some-plugin.lua', {})

-- vim.g.expandtab
vim.cmd [[
    set spelllang=en,cjk
    set encoding=utf-8
    set fileencodings=utf-8,euc-jp,sjis
    set fileformats=unix,dos
    set expandtab
    set tabstop=4
    set shiftwidth=4
    set softtabstop=0
    set ttimeoutlen=50
    set guioptions-=T
    set guioptions-=m
    set wildmenu
    set wildmode=longest:full,full
    syntax enable
    set autoindent
    set nu
    set autochdir

    set virtualedit=all
    set switchbuf=useopen
    set matchpairs& matchpairs+=<:>

    set whichwrap=b,s,h,l,<,>,[,]

    set cursorline
    set title

    set iminsert=0
    set imsearch=-1

    set listchars=tab:>.,trail:_,eol:$,extends:>,precedes:<,nbsp:%

    set modeline
    set foldmethod=marker
    set commentstring=//%s//

    set dictionary=/usr/share/dict/words

    set clipboard=unnamed
    set clipboard^=unnamedplus

    nnoremap ? :/¥<¥><left><left>
    nnoremap tw :tabnew<cr>

    set synmaxcol=200
    set mouse=
]]

keymap('n', ',l', '<c-w>L', opts)
keymap('n', ',j', '<c-w>J', opts)
keymap('n', ',k', '<c-w>K', opts)
keymap('n', ',h', '<c-w>H', opts)

keymap('i', 'jj', '<esc>', opts)
keymap('c', 'jj', '<esc>', opts)
keymap('t', 'jj', '<esc>', opts)
keymap('v', 'mm', '<esc>', opts)

vim.keymap.set('n', '<space>q', function()
    local ctab_nr = vim.fn.tabpagenr()
    vim.cmd('tabn' .. vim.fn.tabpagenr('#'))
    vim.cmd('tabclose' .. ctab_nr)
end)
--keymap('n', '<space>q', ':lua vim.cmd("bd " .. vim.fn.expand("%:t"))<cr>', opts)
--keymap('n', '<space>q', ':lua vim.cmd("bd! " .. vim.api.nvim_buf_get_name(0))<cr>', opts)

keymap('n', 'j', 'gj', opts)
keymap('n', 'k', 'gk', opts)
-- keymap('n', 'v', '<c-v>', opts)
-- keymap('v', '/', '<esc>/\%V', {noremap = true})
keymap('n', '<c-b>', '<c-^>', opts)
keymap('n', '*', '*Nzz', {})
keymap('', '<esc><esc>', ":nohlsearch<cr>", opts)

keymap('n', '<esc><esc>', ':<c-u>nohlsearch<cr>', {}) 

-- change window width
keymap('n', '<left>', '<c-w><<cr>', opts)
keymap('n', '<right>', '<c-w>><cr>', opts)
keymap('n', '<up>', '<c-w>+', opts)
keymap('n', '<down>', '<c-w>-', opts)

-- cmd mode
keymap('c', '<c-a>', '<home>', {})
keymap('c', '<c-b>', '<left>', {})
keymap('c', '<c-f>', '<right>', {})
keymap('c', '<c-d>', '<del>', {})
keymap('c', '<c-e>', '<end>', {})
keymap('c', '<c-n>', '<down>', {})
keymap('c', '<c-p>', '<up>', {})
keymap('c', '<space>;', '<c-r>0', {})

-- set list
keymap('n', '<c-l>', ':set list!<cr>', opts)

keymap('n', '<s-y>', 'y$', opts)

--move easy window
keymap('n', '<space>w', '<c-w>', opts)

-- vnoremap * "zy:let @/ = @z<CR>n
-- keymap('v', '<space>w', '<c-w>', opts)

keymap('n', '<space>l', 'gt', opts)
keymap('n', '<space>h', 'gT', opts)
keymap('n', 'tm', ':tabm', opts)
-- keymap('n', 'tn', ':tabnew<cr>', opts)
keymap('n', 'to', ':tabonly<cr>', opts)
keymap('n', 'tp', ':tab sp<cr>', opts)
keymap('n', 'tl', ':+tabm<cr>', opts)
keymap('n', 'th', ':-tabm<cr>', opts)
-- keymap('n', '<space>x', ':call My_tabclose()<cr>', opts)
-- keymap('n', '<space>q', ':call My_tabclose()<cr>', opts)
keymap('n', '<space>a', 'gg<s-v><s-g>', opts)
keymap('n', '<c-c>', ' :only<cr>', opts)

keymap('n', '<silent>vp', 'gv', opts)
keymap('n', 'dif', ':windo diffthis<cr>', opts)
keymap('n', 'dio', ':diffoff<cr>', opts)
keymap('n', 'vs', ':vnew<cr>', opts)
keymap('n', 'sp', ':new<cr>', opts)

-- settings quickfix
keymap('n', '<space>p', ':cp<cr>', opts)
keymap('n', '<space>n', ':cn<cr>', opts)

keymap('v', '<space>/', '<esc>/\\%V', opts)

-- keymap('n', 'ms', ':Recter<cr>', opts)

keymap('n', 'tbs', 'split enew<cr>', opts)
keymap('n', 'tbv', 'vsplit enew<cr>', opts)

keymap('n', 'ss', ':%s/ *$//g<cr>', opts)


keymap('n', '?', ':/\\<\\><left><left>', {})
-- keymap('n', '/', '/\\v', {})


keymap('n', '<c-w>t', '<c-w>T', opts)
keymap('n', '<c-w><c-t>', '<c-w>T', opts)

keymap('i', '<c-a>', '<c-o>^', opts)
keymap('i', '<c-e>', '<c-o>$', opts)

-- keymap('i', '<c-w>', '<c-o>dB', opts)
keymap('i', '<c-b>', '<left>', opts)


--Remap space as leader key
-- keymap("", "<Space>", "<Nop>", opts)
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

-- Select all
keymap("n", "<c-a>", "gg<S-v>G", opts)

-- Do not yank with x
-- keymap("n", "x", '"_x', opts)

-- Delete a word backwards
keymap("n", "dw", 'vb"_d', opts)

-- terminal
keymap('t', 'jj', [[<C-\><C-n>]], opts)
-- keymap('t', '<c-l>', 'clear<cr>', opts)
keymap('t', '<c-j>', '<return>', opts)


keymap('n', 'da', ':lua vim.diagnostic.open_float()<cr>', opts)
