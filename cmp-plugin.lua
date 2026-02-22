local vim = vim

return {
    -- nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        dependencies = {
            -- cmp series
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-calc",

            -- ultisnips
            -- "L3MON4D3/LuaSnip",
            "SirVer/ultisnips",
            "quangnguyen30192/cmp-nvim-ultisnips",
            -- "saadparwaiz1/cmp_luasnip",
        },
        event = { "InsertEnter", "CmdlineEnter" },
        config = function()
            local cmp = require("cmp")

            require("cmp_nvim_ultisnips").setup({})
            -- ultisnips
            local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
            require("cmp").setup({
                snippet = {
                    expand = function(args)
                        vim.fn["UltiSnips#Anon"](args.body)
                    end,
                },
                sources = {
                    { name = "ultisnips" },
                    -- more sources
                },
                -- recommended configuration for <Tab> people:
                mapping = {
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
                    end, {
                        "i",
                        "s", --[[ "c" (to enable the mapping in command mode) ]]
                    }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        cmp_ultisnips_mappings.jump_backwards(fallback)
                    end, {
                        "i",
                        "s", --[[ "c" (to enable the mapping in command mode) ]]
                    }),
                },
            })

            -- local lspkind = require('lspkind')
            vim.opt.completeopt = { "menu", "menuone", "noselect" }

            cmp.setup({
                -- formatting = {
                --     format = lspkind.cmp_format({
                --         mode = 'symbol',
                --         maxwidth = 50,
                --         ellipsis_char = '...',
                --         before = function(entry, vim_item)
                --             return vim_item
                --         end,
                --     }),
                -- },
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<c-k>"] = cmp.mapping.scroll_docs(-4),
                    ["<c-j>"] = cmp.mapping.scroll_docs(4),
                    ["<c-e>"] = cmp.mapping.abort(),
                    ["<c-l>"] = cmp.mapping.confirm({ select = true }),
                    ["<cr>"] = cmp.mapping.complete(),
                    -- ["<c-space>"] = cmp.mapping.complete(),
                    ["<Tab>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                            -- elseif require("luasnip").expand_or_jumpable() then
                            --   vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                        else
                            fallback()
                        end
                    end,
                    ["<S-Tab>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                            -- elseif require("luasnip").jumpable(-1) then
                            --   vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
                        else
                            fallback()
                        end
                    end,
                    -- ["<cr>"] = cmp.mapping.confirm({select = true})
                }),
                sources = cmp.config.sources({
                    { name = "copilot" },
                    { name = "nvim_lsp" },
                    { name = "nvim_lua" },
                    { name = "ultisnips" },
                    { name = "git" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "calc" },
                }),
            })

            cmp.setup.cmdline("/", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                    { name = "cmdline" },
                }),
            })

            local on_attach = function(client, bufnr)
                vs_buf_def = function()
                    vim.cmd("vs")
                    vim.lsp.buf.definition()
                end
                tab_buf_def = function()
                    vim.cmd("tab sp")
                    vim.lsp.buf.definition()
                end
                local opts = { noremap = true, silent = true }
                vim.lsp.handlers["textDocument/publishDiagnostics"] =
                    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                        virtual_text = false,
                        signs = false,
                        underline = false,
                    })
            end
        end,
    },

    -- ultisnips
    {
        "SirVer/ultisnips",
        config = function()
            vim.g.UltiSnipsExpandTrigger = "<tab>"
            vim.g.UltiSnipsJumpForwardTrigger = "<c-b>"
            vim.g.UltiSnipsJumpBackwardTrigger = "<c-z>"
            vim.g.UltiSnipsEditSplit = "vertical"
        end,
    },

    -- vim-snippets
    {
        -- snippet set
        "honza/vim-snippets",
    },

    -- copilot
    {
        "zbirenbaum/copilot.lua",
        requires = {
            "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
        },
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
            require("copilot.command").disable()
        end,
    },

    {
        "copilotlsp-nvim/copilot-lsp",
    },

    {
        "zbirenbaum/copilot-cmp",
        config = function()
            require("copilot_cmp").setup()
        end,
    },

    {
        {
            "CopilotC-Nvim/CopilotChat.nvim",
            dependencies = {
                { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
                { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
            },
            build = "make tiktoken",
            opts = {
                -- See Configuration section for options
            },
            -- See Commands section for default commands if you want to lazy load on them
            config = function()
                require("CopilotChat").setup({
                    model = "gpt-5",
                    prompts = {
                        Explain = {
                            prompt = "選択したコードの説明を日本語で書いてください",
                            mapping = "<space>ce",
                        },
                        Review = {
                            prompt = "コードを日本語でレビューしてください",
                            mapping = "<space>cr",
                        },
                        Fix = {
                            prompt = "このコードには問題があります。バグを修正したコードを表示してください。説明は日本語でお願いします",
                            mapping = "<space>cf",
                        },
                        Optimize = {
                            prompt = "選択したコードを最適化し、パフォーマンスと可読性を向上させてください。説明は日本語でお願いします",
                            mapping = "<space>co",
                        },
                        Docs = {
                            prompt = "選択したコードに関するドキュメントコメントを日本語で生成してください",
                            mapping = "<space>cd",
                        },
                        Tests = {
                            prompt = "選択したコードの詳細なユニットテストを書いてください。説明は日本語でお願いします",
                            mapping = "<space>ct",
                        },
                        Commit = {
                            prompt = require("CopilotChat.config.prompts").Commit.prompt,
                            mapping = "<space>cco",
                            selection = require("CopilotChat.select").gitdiff,
                        },
                    },
                })
            end, -- See Commands section for default commands if you want to lazy load on them
            keys = {
                {
                    "<space>cc",
                    function()
                        require("CopilotChat").toggle()
                    end,
                    desc = "CopilotChat - Toggle",
                },
                {
                    "<space>cch",
                    function()
                        local actions = require("CopilotChat.actions")
                        require("CopilotChat.integrations.telescope").pick(actions.help_actions())
                    end,
                    desc = "CopilotChat - Help actions",
                },
                {
                    "<space>ccp",
                    function()
                        local actions = require("CopilotChat.actions")
                        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
                    end,
                    desc = "CopilotChat - Prompt actions",
                },
            },
        },
    },
}
