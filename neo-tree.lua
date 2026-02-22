local vim = vim

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
-- vim.opt.termguicolors = true

vim.cmd([[
    :hi      NvimTreeExecFile    guifg=#ffa0a0
    :hi      NvimTreeSpecialFile guifg=#ff80ff gui=underline
    :hi      NvimTreeSymlink     guifg=Yellow  gui=italic
    :hi link NvimTreeImageFile   Title
]])

return {
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            local function my_on_attach(bufnr)
                local api = require("nvim-tree.api")

                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end

                local function edit_or_open()
                    local node = api.tree.get_node_under_cursor()

                    if node.nodes ~= nil then
                        -- expand or collapse folder
                        api.node.open.edit()
                    else
                        -- open file
                        api.node.open.edit()
                        -- Close the tree if file was opened
                        api.tree.close()
                    end
                end

                -- open as vsplit on current node
                local function vsplit_preview()
                    local node = api.tree.get_node_under_cursor()

                    if node.nodes ~= nil then
                        -- expand or collapse folder
                        api.node.open.edit()
                    else
                        -- open file as vsplit
                        api.node.open.vertical()
                    end

                    -- Finally refocus on tree if it was lost
                    api.tree.focus()
                end

                -- default mappings
                api.config.mappings.default_on_attach(bufnr)

                -- custom mappings
                vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
                vim.keymap.set("n", "<c-v>", vsplit_preview, opts("Vsplit Preview"))
                vim.keymap.set("n", "yy", api.fs.copy.node, opts("Copy"))
                vim.keymap.set("n", "yf", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
                vim.keymap.set("n", "dd", api.fs.remove, opts("Remove"))
                vim.keymap.set("n", "N", api.fs.create, opts("Create"))
                vim.keymap.set("n", "h", api.tree.change_root_to_parent, opts("Up"))
                vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            end

            -- OR setup with some options
            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                },
                on_attach = my_on_attach,
            })
        end,
        
        vim.keymap.set("n", "<space>e", "<cmd>NvimTreeToggle %:p:h<cr>"),
        vim.keymap.set("n", "<space>ff", "<cmd>NvimTreeFindFile<cr>"),
    },
}
