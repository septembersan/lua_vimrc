local vim = vim
local NS = { noremap = true, silent = true }

-- vim.diagnostic.disable()


local function feedkeys(keys, mode)
    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(termcodes, mode or "n", false)
end


local function copy_pwd()
    local pid = vim.b.terminal_job_pid
    if not pid then return end
    local cwd = vim.uv.fs_readlink('/proc/' .. pid .. '/cwd')
    if cwd then
      vim.fn.setreg('+', cwd)
      -- vim.notify('Yanked: ' .. cwd)
    end

    return cwd
end


local function find_venv()
  local result = vim.fs.find(".venv", {
    path = vim.fn.expand("%:p:h"),
    upward = true,
    type = "directory",
  })
  return result[1]
end


return {
    -- semshi
    {
      "wookayin/semshi",
       build = ":UpdateRemotePlugins",
       version = "*",  -- Recommended to use the latest release
       init = function()  -- example, skip if you're OK with the default config
         vim.g['semshi#error_sign'] = false
       end,
       config = function()
         -- any config or setup that would need to be done after plugin loading
       end,
    },

    -- iron
    {
        "Vigemus/iron.nvim",
        -- config = true,
        config = function()
            local function get_python_repl()
              -- conda環境がactiveかチェック
              -- if os.getenv("CONDA_DEFAULT_ENV") then
              --   return { "ipython", "--no-confirm-exit", "--colors=Linux", "--no-autoindent" }
              -- end

              -- uvの.venvが存在するかチェック
              local venv = find_venv()
              if venv then
                return { "uv", "run", "ipython", "--no-confirm-exit", "--colors=Linux", "--no-autoindent" }
              else
                return { "ipython", "--no-confirm-exit", "--colors=Linux", "--no-autoindent" }
              end

              -- フォールバック
              return { "ipython" }
            end
            local opts = {
                config = {
                    scratch_repl = true,
                    repl_definition = {
                        sh = {
                            command = { "bash" },
                        },
                        python = {
                            -- command = { "ipython", "--no-confirm-exit", "--colors=Linux", "--no-autoindent" },
                            command = get_python_repl,  -- 関数を渡せる
                            format = require("iron.fts.common").bracketed_paste_python,
                        },
                    },
                    repl_open_cmd = require("iron.view").split.vertical("50%", {
                        number = false,
                    }),
                },
                keymaps = {
                    -- send_motion = "<c-e><c-m>",
                    visual_send = "<c-e><c-v>",
                    send_file = "<c-e><c-f>",
                    send_line = "<c-e><c-e>",
                    send_until_cursor = "<c-e><c-u>",
                    send_mark = "<c-e><c-a>",
                    mark_motion = "<space>mc",
                    mark_visual = "<space>mc",
                    remove_mark = "<space>md",
                    -- send_code_block = "<c-e><c-k>",
                    cr = "<c-e><c-j>",
                    exit = "<c-e><c-c>",
                    -- clear = "<c-e><c-l>",
                    interrupt = "<c-e>c",
                },
                highlight = {
                    italic = false,
                    --fg = "#A9A1E1", -- Optional custom foreground
                    --bg = "#2E3440", -- Optional custom background
                },
                ignore_blank_lines = true,
            }
            require("iron.core").setup(opts)

            send_word_to_repl = function()
                local word = vim.fn.expand("<cword>")
                local iron = require("iron")
                iron.core.send(nil, { word })
            end
            send_clear_to_repl = function()
                local iron = require("iron")
                iron.core.send(nil, { "clear" })
            end
            send_run_to_repl = function()
                local iron = require("iron")
                local command = "run " .. vim.fn.expand("%:p")
                iron.core.send(nil, { command })
            end

            run_ipython = function()
                vim.cmd("IronSend clear")
                send_run_to_repl()
            end

            vim.api.nvim_set_keymap("n", "<c-e><c-f>", ":lua run_ipython()<cr>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap(
                "n",
                "<c-e><c-k>",
                ":lua send_word_to_repl()<cr>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                "<c-e><c-l>",
                ":lua send_clear_to_repl()<cr>",
                { noremap = true, silent = true }
            )
        end,

        vim.keymap.set("n", "<c-e><c-e>", "<cmd>IronRepl<cr>"),
        -- vim.keymap.set("n", "<c-e><c-f>", "<cmd>IronRestart<cr>"),
        vim.keymap.set("n", "<c-e><c-r>", "<cmd>IronFocus<cr>"),
        vim.keymap.set("n", "<c-e><c-h>", "<cmd>IronHide<cr>"),
    },

    -- neoterm
    {
        "kassio/neoterm",
        config = function()
            vim.g.term_id = 1
            vim.g.neoterm_size = 14
            vim.g.neoterm_autoscroll = 1
            vim.g.neoterm_autoinsert = 1
            vim.g.neoterm_default_mod = "belowright"

            new_terminal = function(cwd)
                local cwd = copy_pwd()
                local python_path = vim.fn.system("which python")
                local env_name = string.match(python_path, ".*/envs/(.+)/bin/python")
                if env_name ~= nil then
                    local cmd = " cd " .. cwd .. " &&" .. " conda activate " .. env_name
                    vim.cmd(vim.g.term_id .. "T" .. cmd)
                else
                    local cmd = " cd " .. cwd
                    vim.cmd(vim.g.term_id .. "T" .. cmd)
                end
                vim.cmd(vim.g.term_id .. "Tclear")
                vim.g.term_id = vim.g.term_id + 1
                vim.g.neoterm_size = 10
            end
            new_terminal_sp = function()
                -- local cwd = vim.fn.getcwd()
                vim.cmd("Tnew")
                new_terminal(cwd)
            end
            new_terminal_vs = function()
                -- local cwd = vim.fn.getcwd()
                vim.g.neoterm_size = math.floor(tonumber(vim.fn.winwidth(0)) / 2)
                vim.cmd("vertical Tnew")
                new_terminal(cwd)
            end

            new_terminal_tab = function()
                -- local cwd = vim.fn.getcwd()
                -- local term_size = vim.api.nvim_win_get_height(0)
                vim.cmd.tabnew()
                vim.cmd("Tnew")
                new_terminal(cwd)
                vim.cmd("only")
            end

            new_terminal_tab_dir_hist = function()
                local cwd = vim.fn.getcwd()
                -- local term_size = vim.api.nvim_win_get_height(0)
                vim.cmd.tabnew()
                vim.cmd("Tnew")
                new_terminal(cwd)
                vim.schedule(function()
                    feedkeys("zz\r", "n")
                end)
                vim.cmd("only")
            end

            vim.keymap.set("t", "<c-g><c-g>", "<c-e><c-u>goto -l<cr>goto ")
            vim.keymap.set("t", "<c-g><c-u>", "<c-e><c-u>howdoi -c ")

            vim.keymap.set("n", "tn", ":lua new_terminal_sp()<cr>")
            vim.keymap.set("n", "ts", ":lua new_terminal_vs()<cr>")
            vim.keymap.set("n", "tt", ":lua new_terminal_tab()<cr>")
            -- vim.keymap.set("n", "to", ":lua new_terminal_tab_dir_hist()<cr>")
            -- vim.api.nvim_set_keymap("t", "<c-g>h", "<c-\\><c-n><c-w>h", { noremap = true, silent = true })
            vim.api.nvim_set_keymap(
                "t",
                "<c-g>h",
                "tdir=$(pwd) && cd .. && clear && echo -e $tdir '->'\"\\e[32m $(pwd) \\e[m\"<cr>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap("t", "<c-g><c-l>", "<c-\\><c-n><c-w>l", { noremap = true, silent = true })
            vim.api.nvim_set_keymap(
                "t",
                "<c-g>u",
                "tdir=$(pwd) && tdir=$(pwd) && popd && clear && echo -e \"\\e[32m $(pwd) \\e[m\" '<-' $tdir<cr>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap("t", "<c-g><c-r>", "ranger<cr>", { noremap = true, silent = true })
            vim.keymap.set('t', '<c-g><c-y>', copy_pwd)
            vim.api.nvim_set_keymap(
                "t",
                "<c-o>",
                "tdir=$(pwd) && zz && clear && echo -e $tdir '->'\"\\e[32m $(pwd) \\e[m\"<cr>",
                { noremap = true, silent = true }
            )
        end,
    },

    -- toggleterm の例
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = {
            direction = "float",
            start_in_insert = true,
            float_opts = {
              border = "rounded",
            },

        },
        config = function()
            vim.g.is_toggle_term_opend = 0
            require("toggleterm").setup({})
            new_terminal_tf = function()
                local cwd = vim.fn.getcwd()
                local python_path = vim.fn.system("which python")
                local env_name = string.match(python_path, ".*/envs/(.+)/bin/python")
                if env_name ~= nil then
                    if vim.g.is_toggle_term_opend == 0 then
                        vim.cmd("ToggleTerm direction=float")
                        local cmd = " cd " .. cwd .. " &&" .. " conda activate " .. env_name .. " &&" .. " clear"
                        vim.cmd(string.format("TermExec cmd='%s'", cmd))
                    else
                        vim.cmd("ToggleTerm direction=float")
                    end
                    vim.schedule(function()
                        vim.cmd("startinsert")
                    end)
                else
                    vim.cmd("ToggleTerm direction=float")
                    local cmd = " cd " .. cwd
                    vim.cmd(string.format("TermExec cmd='%s'", cmd))
                    vim.schedule(function()
                        vim.cmd("startinsert")
                    end)
                end
                vim.g.is_toggle_term_opend = 1
            end
            new_terminal_to = function()
                local cmd = "zz"
                vim.cmd(string.format("TermExec cmd='%s'", cmd))
                vim.schedule(function()
                    vim.cmd("startinsert")
                end)
                local term = require("toggleterm.terminal").get(1)
                if term then
                  vim.api.nvim_chan_send(term.job_id, "\x15")  -- Ctrl-U のASCIIコード
                end
            end
            toggle_term_close = function()
                vim.schedule(function()
                    vim.cmd("startinsert")
                end)
                local term = require("toggleterm.terminal").get(1)
                if term then
                  vim.api.nvim_chan_send(term.job_id, "\x15")  -- Ctrl-U のASCIIコード
                end
                vim.schedule(function()
                    vim.cmd("stopinsert")
                end)
                vim.cmd("ToggleTerm")
            end
            -- vim.api.nvim_set_keymap("n", "<c-m>", ":lua new_terminal_tf()<cr>", { noremap = true, silent = true })
            -- vim.keymap.set("t", "<c-o>", new_terminal_to, { silent = true })
            -- -- vim.api.nvim_set_keymap("t", "<c-m>", ":lua new_terminal_tf()<cr>", { noremap = true, silent = true })
            -- vim.keymap.set("t", "<c-m>", toggle_term_close, { silent = true })
        end,
    },

    -- lualine
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "ayu_mirage",
                    -- theme = 'carbonfox',
                    -- disabled_filetypes = {
                    --     winbar = {
                    --         'dap-repl',
                    --         "dapui_breakpoints",
                    --         "dapui_console",
                    --         "dapui_scopes",
                    --         "dapui_watches",
                    --         "dapui_stacks",
                    --     },
                    -- },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                tabline = {
                    lualine_a = {
                        {
                            "tabs",
                            fmt = function(name, context)
                                local buflist = vim.fn.tabpagebuflist(context.tabnr)
                                local winnr = vim.fn.tabpagewinnr(context.tabnr)
                                local bufnr = buflist[winnr]
                                local mod = vim.fn.getbufvar(bufnr, "&mod")

                                return name .. (mod == 1 and " [+]" or "")
                            end,
                            mode = 1,
                            show_filename_only = true,
                            show_modified_status = true,
                            symbols = { modified = "", alternate_file = " ", directory = " " },
                            filetype_names = {
                                TelescopePrompt = "Telescope",
                                dashboard = "Dashboard",
                                fzf = "FZF",
                            },
                        },
                    },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {
                        "diff",
                    },
                    lualine_y = {
                        "branch",
                    },
                    lualine_z = {
                        { "tabs" },
                    },
                },
                winbar = {},
                inactive_winbar = {},
                extensions = {},
            })
        end,
    },

    -- align
    -- {
    --   'junegunn/vim-easy-align',
    --   keys = {
    --     { "<space>a", '<plug>(EasyAlign)', desc = "" , mode='x'},
    --   },
    -- },

    -- resize-mode
    {
        "simeji/winresizer",
        keys = {
            { "mr", ":WinResizerStartResize<cr>", { noremap = true } },
        },
    },

    -- hologram
    -- {
    --     'edluffy/hologram.nvim',
    --     config = function()
    --         require('hologram').setup {
    --             auto_display = true -- WIP automatic markdown image display, may be prone to breaking
    --         }
    --     end,
    -- },

    -- comment
    {
        "numToStr/Comment.nvim",
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
                mappings = {
                    basic = false,
                },
            })
        end,

        vim.keymap.set("n", "cc", "<Plug>(comment_toggle_linewise_current)"),
        vim.keymap.set("v", "cc", "<Plug>(comment_toggle_linewise_visual)"),
    },

    -- ts-context
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
            require("ts_context_commentstring").setup({
                enable_autocmd = false,
            })
        end,
    },

    -- vim-quickhl
    {
        "t9md/vim-quickhl",
        vim.keymap.set("n", "<space>s", "<Plug>(quickhl-manual-this)"),
        vim.keymap.set("n", "<space>se", "<Plug>(quickhl-manual-reset)"),
    },

    -- align
    {
        "Vonr/align.nvim",
        branch = "v2",
        lazy = true,
        -- vim.keymap.set('x', '<space>a',
        --     function()
        --         require'align'.align_to_char({ length = 1, })
        --     end
        -- ),
        -- Aligns to 2 characters with previews
        vim.keymap.set("x", "<space>a", function()
            require("align").align_to_char({ length = 2 })
        end, NS),
    },

    -- hlargs
    {
        "m-demare/hlargs.nvim",
        config = function()
            require("hlargs").setup()
        end,
    },

    -- night fox
    {
        "EdenEast/nightfox.nvim",
        config = function()
            require("nightfox").setup({})
            vim.cmd("colorscheme carbonfox")
        end,
    },

    -- {
    --   "folke/tokyonight.nvim",
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --       vim.cmd("colorscheme tokyonight-night")
    --   end,
    -- },

    -- iceberg
    -- {
    --     "oahlen/iceberg.nvim",
    --     config = function()
    --         vim.cmd("colorscheme iceberg")
    --     end,
    -- },

    -- catppuccin
    -- {
    --     'catppuccin/nvim',
    --     priority = 1000,
    --     config = function()
    --         vim.cmd("colorscheme catppuccin")
    --     end,
    -- },

    -- ayu
    -- {
    --     'ayu-theme/ayu-vim',
    --     config = function()
    --         vim.opt.termguicolors = true
    --
    --         -- Set the ayucolor theme
    --         -- vim.g.ayucolor = "light" -- for light version of theme
    --         -- vim.g.ayucolor = "mirage" -- for mirage version of theme
    --         vim.g.ayucolor = "dark"   -- for dark version of theme
    --
    --         -- Apply the colorscheme
    --         vim.cmd("colorscheme ayu")
    --     end,
    -- },

    -- nvim-scrollbar
    {
        "petertriho/nvim-scrollbar",
        config = function()
            require("scrollbar").setup()
        end,
    },

    -- substitute
    {
        "gbprod/substitute.nvim",
        config = function()
            require("substitute").setup()
            vim.keymap.set("n", "t", require("substitute").operator, { noremap = true })
            -- vim.keymap.set("n", "tl", require('substitute').line, { noremap = true })
            -- vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
            vim.keymap.set("x", "t", require("substitute").visual, { noremap = true })
        end,
    },

    -- save-clipboard-on-exit
    {
        "yutkat/save-clipboard-on-exit.nvim",
    },

    -- csv-tools
    -- {
    --     "Decodetalkers/csv-tools.lua",
    --     config = function()
    --         require("csvtools").setup({
    --             before = 10,
    --             after = 10,
    --             clearafter = true,
    --             -- this will clear the highlight of buf after move
    --             showoverflow = true,
    --             -- this will provide a overflow show
    --             titelflow = true,
    --             -- add an alone title
    --         })
    --     end,
    -- },

    -- -- auto-session
    -- {
    --     "rmagatti/auto-session",
    --     lazy = false,
    --
    --     ---enables autocomplete for opts
    --     ---@module "auto-session"
    --     ---@type AutoSession.Config
    --     opts = {
    --         suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    --         auto_restore_last_session = false,
    --         -- cwd_change_handling = true,
    --         -- log_level = 'debug',
    --     },
    --     -- config = function()
    --     --     require("auto-session").setup()
    --     -- end,
    -- },

    -- marks
    {
        "chentoast/marks.nvim",
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("marks").setup({
                mappings = {
                    toggle = "mm",
                    next = "mn",
                    preview = "mp",
                    set_bookmark0 = "m0",
                    prev = false, -- pass false to disable only this default mapping
                },
            })
        end,
    },

    -- log
    {
        'fei6409/log-highlight.nvim',
        opts = {},
    },
}
