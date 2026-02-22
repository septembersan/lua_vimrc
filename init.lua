vim.g.python3_host_prog = vim.fn.exepath("python3")
require("config.lazy")
require("keymaps")
-- vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.o.sessionoptions = "localoptions"
vim.o.signcolumn = "yes:1"
vim.o.number = true
-- vim.env.CONDA_DEFAULT_ENV = nil
-- vim.env.CONDA_PREFIX = nil
-- vim.env.CONDA_PYTHON_EXE = nil
-- または具体的なパスを指定
-- vim.g.python3_host_prog = "/usr/bin/python3"
-- vim.opt.cmdheight = 0

-- auto save session
vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    callback = function()
        vim.cmd("mksession! " .. vim.fn.stdpath("config") .. "/session.vim")
    end,
})

-- 起動時に自動的にセッションを読み込み
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        local session_file = vim.fn.stdpath("config") .. "/session.vim"
        if vim.fn.filereadable(session_file) == 1 then
            vim.cmd("source " .. session_file)
        end
    end,
})
