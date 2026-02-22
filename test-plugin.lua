local vim = vim

local function find_venv()
  local result = vim.fs.find(".venv", {
    path = vim.fn.expand("%:p:h"),
    upward = true,
    type = "directory",
  })
  return result[1]
end

return {
    -- neotest-python
    {
        "nvim-neotest/neotest-python",
    },

    -- neotest
    {
        "nvim-neotest/neotest",
        -- lazy = true,
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-neotest/neotest-python",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            -- disable diagnostic in neotest only
            -- local neotest_ns = vim.api.nvim_create_namespace("neotest")
            -- vim.diagnostic.config({
            --     virtual_text = false
            -- }, neotest_ns)

            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        runner = "pytest",
                        args = { "-s", "-vv" },
                        python = function()
                            -- local cwd = vim.fn.getcwd()
                            local venv_path = find_venv()
                            if venv_path then
                                local venv_python = venv_path .. '/bin/python'
                                -- vim.notify(venv_python)
                                return venv_python
                            end
                            -- vim.notify('python')
                            return 'python'
                        end,
                    }),
                    -- require("neotest-plenary"),
                    -- require("neotest-vim-test")({
                    --     ignore_file_types = { "python", "vim", "lua" },
                    -- }),
                },
                icons = {
                    passed = "✔️",
                    running = "🔄",
                    -- failed = '❌',
                    skipped = "➡️",
                    unknown = "❓",
                    error = "❌",
                },
            })

            neotest_attach_vs = function()
                require("neotest").run.attach()
                vim.cmd("vs")
            end
            neotest_tpf_attach_vs = function()
                require("neotest").run.run()
                vim.wait(100)
                require("neotest").run.attach()
                vim.cmd("vs")
            end
            vim.keymap.set("n", "tpf", '<cmd>lua neotest_tpf_attach_vs()<cr>')
            vim.keymap.set("n", "tpa", "<cmd>lua neotest_attach_vs()<cr>")
            vim.keymap.set("n", "tpj", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>')
            vim.keymap.set("n", "tpd", function()
                require("neotest").run.run({strategy = "dap"})
                require('dapui').open()
            end)
                -- '<cmd>lua require("neotest").run.run({strategy = "dap"})<cr>')
            vim.keymap.set("n", "tpl", '<cmd>lua require("neotest").run.run_last({status = "failed"})<cr>')
            vim.keymap.set("n", "tpo", '<cmd>lua require("neotest").summary.open()<cr>')
            vim.keymap.set("n", "[t", '<cmd>lua require("neotest").jump.prev({ status = "failed" })<cr>')
            vim.keymap.set("n", "]t", '<cmd>lua require("neotest").jump.next({ status = "failed" })<cr>')
            vim.keymap.set("n", "tpp", '<cmd>lua require("neotest").output.open({ enter = true, short = false })<cr>')
        end,
    },
}
