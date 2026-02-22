local vim = vim

local lsp_list = {
    "basedpyright",
}
vim.lsp.config("*", {})
vim.lsp.enable(lsp_list)

vs_buf_def = function()
    vim.cmd("vs")
    vim.lsp.buf.definition()
end

tab_buf_def = function()
    vim.cmd("tab sp")
    vim.lsp.buf.definition()
end

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<c-j><c-j>", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
vim.keymap.set("n", "<c-j><c-v>", "<cmd>lua vs_buf_def()<cr>", opts)
vim.keymap.set("n", "<c-j><c-t>", "<cmd>lua tab_buf_def()<cr>", opts)
vim.keymap.set("n", "<c-j><c-k>", "<cmd>lua vim.lsp.buf.hover()<cr>")
vim.keymap.set("n", "<c-j><c-m>", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
-- vim.keymap.set("n", "rn", "<cmd>lua vim.lsp.buf.rename()<cr>")
vim.keymap.set("n", "<c-j><c-a>", "<cmd>lua vim.lsp.buf.code_action()<cr>")
vim.keymap.set("n", "<c-j><c-r>", "<cmd>lua vim.lsp.buf.references()<cr>")
vim.keymap.set("n", "<c-a><c-f>", "<cmd>lua vim.lsp.buf.format()<cr>")


return {
    -- mason
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end,
        cmd = "Mason",
    },
    -- mason-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = lsp_list,
            })
        end,
    },

    -- lspkind (icons like vscode)
    {
        "onsails/lspkind.nvim",
        event = "InsertEnter",
    },

    -- lspsaga
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        event = { "BufRead", "BufNewFile" },
        config = function()
            require("lspsaga").setup({
                symbol_in_winbar = {
                    separator = "  ",
                    enable = true,
                },
            })
        end,
    },

    -- aerial.nvim
    {
        "stevearc/aerial.nvim",
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
       },
        config = function()
            require("aerial").setup({
                keymaps = {
                    ["<c-l>"] = "actions.jump",
                },
            })
            vim.api.nvim_set_keymap("n", "<space>t", "<cmd>AerialToggle left<cr>", { noremap = true, silent = true })
        end,
    },

}

