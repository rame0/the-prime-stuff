---@class WindowPosition
---@field width number
---@field height number
---@field row number
---@field col number

---@class WindowDetails
---@field dim WindowPosition
---@field buffer number
---@field win_id number

local group = vim.api.nvim_create_augroup("vim-with-me.window", {
    clear = true,
})

local M = {}

---@param width number
---@param height number
---@return WindowPosition
function M.create_window_offset(width, height)
    return {
        width = width,
        height = height,
        row = 0,
        col = 0,
    }
end

---@param details WindowDetails
function M.close_window(details)
    local win_id = details.win_id
    local buffer = details.buffer

    if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
    end

    if buffer ~= nil and vim.api.nvim_buf_is_valid(buffer) then
        vim.api.nvim_buf_delete(buffer, { force = true })
    end
end

---@param offset WindowPosition
---@return WindowPosition
function M.get_window_dim(offset)
    offset = offset or M.create_window_offset(2, 2)
    local ui = vim.api.nvim_list_uis()[1]
    local width = 40
    local height = 20
    if ui ~= nil then
        width = math.max(ui.width, 0)
        height = math.max(ui.height, 0)
    end

    return {
        width = math.max(width - offset.width, 0),
        height = math.max(height - offset.height, 0),
        row = offset.row,
        col = offset.col,
    }
end

---@param pos WindowPosition
function M.create_window_config(pos)
    return {
        relative = "editor",
        anchor = "NW",
        row = pos.row,
        col = pos.col,
        width = pos.width,
        height = pos.height,
        border = "none",
        title = "",
        style = "minimal",
    }
end

---@param dim WindowPosition | nil
---@return WindowDetails
function M.create_window(dim)
    dim = dim or M.create_window_offset(80, 24)
    local buffer = vim.api.nvim_create_buf(false, true)
    local config = M.create_window_config(dim)
    local win_id = vim.api.nvim_open_win(buffer, false, config)

    return {
        dim = dim,
        buffer = buffer,
        win_id = win_id,
    }
end

---@param details WindowDetails
---@return boolean
local function clear_if_invalid(details)
    if not vim.api.nvim_win_is_valid(details.win_id) then
        vim.api.nvim_clear_autocmds({
            group = group,
        })
        return true
    end
    return false
end

---@param details WindowDetails
---@param pos WindowPosition | nil
function M.resize(details, pos)
    pos = pos or M.create_window_offset(2, 2)
    if clear_if_invalid(details) then
        return
    end

    details.dim = M.get_window_dim(pos)
    local config = M.create_window_config(details.dim)
    vim.api.nvim_win_set_config(details.win_id, config)
end

---@param details WindowDetails
---@param cb function
function M.on_close(details, cb)
    vim.api.nvim_create_autocmd("BufUnload", {
        group = group,
        buffer = details.buffer,
        callback = function()
            if clear_if_invalid(details) then
                return
            end
            cb()
        end,
    })
end

function M.refocus(details)
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function()
            if clear_if_invalid(details) then
                return
            end
            vim.api.nvim_set_current_win(details.win_id)
        end,
    })
end

return M
