local map = vim.keymap.set
local vscode = require "vscode"

local vsmap = function(mode, key, action)
    map(mode, key, function()
        vscode.action(action)
    end)
end

map("i", "jk", "<ESC>")
map("n", "<leader>ds", function()
    require("scripts.go.struct_copy").generate_and_copy_to_register ""
end)

vsmap("n", "gr", "editor.action.goToReferences")
vsmap("n", "<Tab>", "workbench.action.nextEditorInGroup")
vsmap("n", "<C-l>", "workbench.action.navigateRight")
vsmap("n", "<C-h>", "workbench.action.navigateLeft")
vsmap("n", "<C-j>", "workbench.action.navigateUp")
vsmap("n", "<C-k>", "workbench.action.navigateDown")
vsmap("n", "<leader>tt", "go.test.cursor")

require'nvim-treesitter.configs'.setup {
    textobjects = {
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]]"] = "@function.outer"
            },
            goto_next_end = {},
            goto_previous_start = {
                ["[["] = "@function.outer"
            },
            goto_previous_end = {},
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
                -- ["]d"] = "@conditional.outer"
            },
            goto_previous = {
                -- ["[d"] = "@conditional.outer"
            }
        },
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@parameter.outer",
                ["ic"] = "@class.inner",
                ["as"] = {
                    query = "@local.scope",
                    query_group = "locals",
                    desc = "Select language scope"
                }
            },
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>' -- blockwise
            },

            include_surrounding_whitespace = true
        }
    }
}
