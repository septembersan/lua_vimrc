

-- return {
--     require("lspconfig").lua_ls.setup({
--       settings = {
--         Lua = {
--           runtime = { version = "LuaJIT" },
--           diagnostics = {
--             globals = { "vim" },  -- vimグローバルを認識させる
--           },
--           workspace = {
--             library = vim.api.nvim_get_runtime_file("", true),  -- Neovim APIの補完・型チェック
--             checkThirdParty = false,
--           },
--         },
--       },
--     }),
-- }
