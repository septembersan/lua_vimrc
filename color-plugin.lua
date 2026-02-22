local vim = vim

-- Define a function to set the highlight group using vim.cmd
local function set_visual_highlight()
  vim.cmd([[
    highlight Visual term=underline ctermfg=195 ctermbg=30 guifg=#c6c8d1 guibg=#5b7881
  ]])
end

-- Create autocommands for VimEnter, WinEnter, and ColorScheme events
vim.api.nvim_create_autocmd({"VimEnter", "WinEnter", "ColorScheme"}, {
  callback = set_visual_highlight
})

return {
}
