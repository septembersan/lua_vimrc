local vim = vim

return {
    {
        "bfredl/nvim-luadev",
        config = function()
            vim.keymap.set('n', '<space>ll', '<Plug>(Luadev-RunLine)', {silent = true})
            vim.keymap.set('v', '<space>lr', '<Plug>(Luadev-Run)', {silent = true})
            vim.keymap.set('n', '<space>le', '<Plug>(Luadev-RunWord)', {silent = true})
        end
    },
}
