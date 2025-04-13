vim.g.mapleader = " "
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system {"git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath}
end
vim.opt.rtp:prepend(lazypath)

if vim.g.vscode then
    require("lazy").setup {{{
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    }, {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter"
    }}}
    vim.schedule(function()
        require "mappings_vscode"
    end)
else
    local lazy_config = require "configs.lazy"

    -- load plugins
    require("lazy").setup({{
        "NvChad/NvChad",
        lazy = false,
        branch = "v2.5",
        import = "nvchad.plugins"
    }, {
        import = "plugins"
    }}, lazy_config)

    -- load theme
    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")

    require "options"
    require "nvchad.autocmds"
    require "configs.tree"

    vim.schedule(function()
        require "mappings"
    end)
end
