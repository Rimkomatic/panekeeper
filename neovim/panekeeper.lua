-- File: lua/custom/panekeeper.lua
-- Description: Seamless Tmux pane-aware session management using mini.sessions

local M = {}

local function get_tmux_session()
    if vim.env.TMUX == nil then
        return nil
    end

    -- Grab the unique internal Tmux ID for this specific terminal environment
    local pane_id = vim.env.TMUX_PANE
    if not pane_id then
        return nil
    end

    -- Explicitly target (-t) this specific pane ID
    local cmd = "tmux display-message -p -t '" .. pane_id .. "' '#S_#I_#P'"
    local session = vim.fn.system(cmd):gsub("\n", "")

    if session == "" then
        return nil
    end

    return session
end

function M.setup()
    -- Ensure mini.sessions is actually available before running
    local has_mini_sessions, mini_sessions = pcall(require, "mini.sessions")
    if not has_mini_sessions then
        vim.notify("tmux-session requires mini.sessions to be installed.", vim.log.levels.ERROR)
        return
    end

    -- 1. The Load Command (Triggered externally by your bash script)
    vim.api.nvim_create_user_command("TmuxSessionLoad", function()
        local session = get_tmux_session()
        if not session then return end

        -- pcall ensures we don't throw errors if the session doesn't exist yet
        pcall(function()
            mini_sessions.read(session)
        end)
    end, {})

    -- 2. The Silent Auto-Save (Runs continuously in the background)
    vim.api.nvim_create_autocmd({ "BufWritePost", "CursorHold" }, {
        desc = "Auto-save Tmux/Neovim session state",
        callback = function()
            local session = get_tmux_session()
            if session then
                mini_sessions.write(session)
            end
        end,
    })
    
    -- Optional: Manual keymaps if a user still wants them
    vim.keymap.set("n", "<leader>sl", "<cmd>TmuxSessionLoad<CR>", { desc = "Load tmux session" })
end

return M
