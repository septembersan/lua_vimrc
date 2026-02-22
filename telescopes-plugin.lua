local vim = vim

return {
    -- telescope
    {
        "nvim-telescope/telescope.nvim",
        requires = {
            "nvim-telescope/telescope-ghq.nvim",
        },
        tag = "0.1.8",
        keys = {
            { "<space>o",  "<cmd>Telescope oldfiles<cr>" },
            { "<space>m",  "<cmd>Telescope resume<cr>" },
            { "<space>bl", "<cmd>Telescope current_buffer_fuzzy_find<cr>" },
            { "<space>bf", "<cmd>Telescope buffers<cr>" },
            { "<space>gg", "<cmd>lua live_grep_from_project_git_root()<cr>" },
            { "<space>gf", "<cmd>Telescope git_files<cr>" },
            { "<space>gj", "<cmd>lua search_cursor_word()<cr>" },
            -- {
            --   "gss",
            --   function() require("telescope.builtin").git_status() end,
            --   {noremap = true}
            -- },
        },
        -- change some options
        config = function()
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")

            local function is_git_repo()
                vim.fn.system("git rev-parse --is-inside-work-tree")

                return vim.v.shell_error == 0
            end
            local function get_git_root()
                local dot_git_path = vim.fn.finddir(".git", ".;")
                return vim.fn.fnamemodify(dot_git_path, ":h")
            end

            search_cursor_word = function()
                local word = vim.fn.expand("<cword>")
                local builtin = require("telescope.builtin")

                local cwd = ""
                if is_git_repo() then
                    cwd = get_git_root()
                end
                builtin.grep_string({ search = word, cwd = cwd })
            end
            -- vim.keymap.set('n', '<space>gj', '<cmd>lua search_cursor_word()<cr>')

            -- live grep in git
            opts = {
                defaults = {
                    layout_strategy = "horizontal",
                    --layout_config = { prompt_position = "top" },
                    --sorting_strategy = "ascending",
                    winblend = 0,
                    mappings = {
                        i = {
                            ["<c-u>"] = false,
                            --['<c-b>'] = require('telescope.actions').results_scrolling_left,
                            ["<c-e>"] = false,
                            ["<c-a>"] = false,
                            ["<c-t>"] = require("telescope.actions").select_tab,
                            ["<c-l>"] = require("telescope.actions").select_default,
                            ["<c-v>"] = require("telescope.actions").select_vertical,
                            ["<c-s>"] = require("telescope.actions").select_horizontal,
                        },
                        n = {
                            -- ['<s-v>'] = ,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        mappings = {
                            n = {
                                ["cd"] = function(prompt_bufnr)
                                    local selection = require("telescope.actions.state").get_selected_entry()
                                    local dir = vim.fn.fnamemodify(selection.path, ":p:h")
                                    require("telescope.actions").close(prompt_bufnr)
                                    -- Depending on what you want put `cd`, `lcd`, `tcd`
                                    vim.cmd(string.format("silent lcd %s", dir))
                                end,
                            },
                        },
                    },
                },
            }
            require("telescope").setup(opts)

            function live_grep_from_project_git_root()
                local opts = {}

                if is_git_repo() then
                    opts = {
                        cwd = get_git_root(),
                    }
                end

                require("telescope.builtin").live_grep(opts)
            end
        end,
    },

    -- telescope-fzf-native
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
            require("telescope").setup({
                extensions = {
                    fzf = {
                        fuzzy = true, -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true, -- override the file sorter
                        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    },
                },
            })
            -- To get fzf loaded and working with telescope, you need to call
            -- load_extension, somewhere after setup function:
            require("telescope").load_extension("fzf")
        end,
    },

    -- telescope-ghq
    {
        "nvim-telescope/telescope-ghq.nvim",
        keys = {
            {
                "<space>gr",
                "<cmd>Telescope ghq<cr>",
                { noremap = true },
            },
        },
        config = function()
            require("telescope").setup(opts)
            require("telescope").load_extension("ghq")
        end,
    },

    -- nvim-neoclip
    {
        "AckslD/nvim-neoclip.lua",
        keys = {
            {
                "<space>y",
                "<cmd>Telescope neoclip<cr>",
                { noremap = true },
            },
        },
        dependencies = {
            { "kkharji/sqlite.lua",           module = "sqlite" },
            { "nvim-telescope/telescope.nvim" },
        },
        config = function()
            require("neoclip").setup({
                keys = {
                    telescope = {
                        i = {
                            select = "<c-j>",
                            paste = "<nop>",
                            paste_behind = "<nop>",
                            replay = "<c-q>", -- replay a macro
                            delete = "<c-d>", -- delete an entry
                            edit = "<c-e>", -- edit an entry
                            custom = {},
                        },
                        n = {
                            select = "<cr>",
                            paste = "p",
                            --- It is possible to map to more than one key.
                            -- paste = { 'p', '<c-p>' },
                            paste_behind = "P",
                            replay = "q",
                            delete = "d",
                            edit = "e",
                            custom = {},
                        },
                    },
                },
            })
        end,
    },
}
