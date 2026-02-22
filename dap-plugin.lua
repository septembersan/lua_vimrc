local vim = vim

local daps = {
    -- python
    "debugpy",

    -- bash
    "bash-debug-adapter",
}

local create_venv_python_cmd = function()
    local cwd = vim.fn.getcwd()
    local venv_python = cwd .. '/.venv/bin/python'
    if vim.fn.executable(venv_python) == 1 then
        -- vim.notify(venv_python)
        return venv_python
    end
    -- vim.notify('python')
    return 'python'
end

return {
    -- dap
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require('dap')

            local function map(key, fn, desc)
                vim.keymap.set('n', key, fn, { desc = desc, buffer = 0 })
            end

            local function unmap(key)
                pcall(vim.keymap.del, "n", key, { buffer = 0 })
            end

            vim.keymap.set("n", "<c-e><c-b>", function() require("dap").toggle_breakpoint() end)
            vim.keymap.set("n", "<c-e><c-d>", function() require("dap").continue() end)
            -- vim.keymap.set("n", "<space>dr", function() require("dap").repl.open() end)
            dap.listeners.after.event_initialized['my_keymaps'] = function()
                map('<c-n>', dap.step_over)
                map('<c-s>', dap.step_into)
                map('<c-r>', dap.step_out)
                map("<c-e><c-l>", dap.run_last)
                vim.keymap.set({ "n", "v" }, "<space>dh", function() require("dap.ui.widgets").hover() end)
                vim.keymap.set({ "n", "v" }, "<c-p>", function() require("dap.ui.widgets").preview() end)
                -- map("<c-e><c-e>", function()
                --   vim.ui.input({ prompt = "Eval: " }, function(expr) 
                --         if expr then require("dapui").eval(expr) end
                --     end)
                -- end)
            end

            -- vim.keymap.set("n", "<F11>", function()
            --     require("dap").step_into()
            -- end)
            -- vim.keymap.set("n", "<F12>", function()
            --     require("dap").step_out()
            -- end)
            -- vim.keymap.set('n', '<Leader>lp',
            --     function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)

            vim.keymap.set("n", "<space>df", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.frames)
            end)
            vim.keymap.set("n", "<space>ds", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes)
            end)

            local function remove_keymaps()
               for _, key in ipairs({ "<c-s>", "<c-n>", "<c-r>", "<c-e><c-e>" }) do
                   unmap(key)
               end
            end

            dap.listeners.before.event_terminated["my_keymaps"] = remove_keymaps
            dap.listeners.before.event_exited["my_keymaps"] = remove_keymaps
        end,
    },

    -- com-dap
    {
        "rcarriga/cmp-dap",
        config = function()
            local cmp = require("cmp")
            require("cmp").setup({
                enabled = function()
                    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
                end,
                -- mapping = {
                --     ["<c-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                --     ["<c-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                -- },
            })

            require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
                sources = {
                    { name = "dap" },
                },
            })
        end,
    },

    -- nvim-dap-repl-highlights
    {
        "LiadOz/nvim-dap-repl-highlights",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        lazy = false,
        config = function()
            require("nvim-dap-repl-highlights").setup()
            require("nvim-treesitter.configs").setup({
              ensure_installed = { "dap_repl" },
            })
        end,
    },

    -- dap-python
    {
        "mfussenegger/nvim-dap-python",
        config = function()
            require("dap-python").setup(create_venv_python_cmd())
            -- require("dap-python").test_runner = 'pytest'
        end,
    },

    -- dap-ui
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            'nvim-neotest/nvim-nio',
            {"theHamsta/nvim-dap-virtual-text", opts = {}}
        },
        config = function()
            require("dapui").setup({
                layouts = {
                    -- {
                    --     elements = {
                    --         { id = "watches",     size = 0.20 },
                    --         { id = "stacks",      size = 0.20 },
                    --         { id = "breakpoints", size = 0.20 },
                    --         { id = "scopes",      size = 0.40 },
                    --     },
                    --     position = "left",
                    --     size = 40,
                    -- },
                    {
                        elements = {
                            { id = "console", size = 0.5 },
                            { id = "repl",    size = 0.5 },
                        },
                        position = "bottom",
                        size = 30,
                    },
                },
            })
            vim.keymap.set("n", "<space>da", function()
                require('dapui').toggle()
            end)
            -- -- auto open and close
            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },

    -- mason-nvim-dap
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            ensure_installed = daps,
            handlers = {},
        },
    },

}
