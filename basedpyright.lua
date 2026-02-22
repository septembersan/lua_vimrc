local function find_venv()
  local result = vim.fs.find(".venv", {
    path = vim.fn.expand("%:p:h"),
    upward = true,
    type = "directory",
  })
  return result[1]
end

local function get_python_path()
    local venv_path = find_venv()
    vim.notify(venv_path .. 'kyou')
    if venv_path then
        return venv_path .. '/bin/python'
    end

    -- -- 1. uv の .venv
    -- local venv = vim.fn.getcwd() .. "/.venv"
    -- if vim.fn.isdirectory(venv) == 1 then
    --     return venv .. "/bin/python"
    -- end

    -- -- 2. activate済み venv
    -- if os.getenv("VIRTUAL_ENV") then
    --     return os.getenv("VIRTUAL_ENV") .. "/bin/python"
    -- end

    -- 3. conda
    -- if os.getenv("CONDA_PREFIX") then
    --     return os.getenv("CONDA_PREFIX") .. "/bin/python"
    -- end

    return "python"
end

return {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", ".git", "setup.py", "requirements.txt" },
    before_init = function(_, config)
        config.settings.python = config.settings.python or {}
        config.settings.python.pythonPath = get_python_path()
    end,
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            },
        },
    },
}
