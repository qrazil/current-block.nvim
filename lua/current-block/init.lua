-- current-block.nvim
-- A plugin to highlight the current code block under the cursor

local M = {}

-- Default configuration
local config = {
    -- Highlight group for the current block
    highlight_group = "CurrentBlock",
    -- Update delay in milliseconds
    debounce_ms = 100,
    -- Enable/disable the plugin
    enabled = true,
    -- Blend level for transparency (0-100, where 0 is fully transparent and 100 is opaque)
    blend = 30,
}

-- Namespace for extmarks
local ns = vim.api.nvim_create_namespace("current_block_highlight")
local timer = nil

-- Get the indentation level of a line
local function get_indent_level(line)
    local indent = line:match("^%s*")
    return #indent
end

-- Check if a line is empty or only whitespace
local function is_empty_line(line)
    return line:match("^%s*$") ~= nil
end

-- Find the start and end of the current block
local function find_block_range(bufnr, cursor_line)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if #lines == 0 then
        return nil, nil
    end

    -- Get current line's indent level
    local current_line = lines[cursor_line]
    if is_empty_line(current_line) then
        return nil, nil
    end

    local current_indent = get_indent_level(current_line)

    -- Find block start (go up until we find a line with less or equal indent that's not empty)
    local block_start = cursor_line
    for i = cursor_line - 1, 1, -1 do
        local line = lines[i]
        if not is_empty_line(line) then
            local indent = get_indent_level(line)
            if indent < current_indent then
                break
            end
            block_start = i
        end
    end

    -- Find block end (go down until we find a line with less indent that's not empty)
    local block_end = cursor_line
    for i = cursor_line + 1, #lines do
        local line = lines[i]
        if not is_empty_line(line) then
            local indent = get_indent_level(line)
            if indent < current_indent then
                break
            end
            block_end = i
        end
    end

    return block_start, block_end
end

-- Clear all highlights
local function clear_highlights(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

-- Highlight the current block
local function highlight_block()
    if not config.enabled then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor[1]

    -- Clear previous highlights
    clear_highlights(bufnr)

    -- Find block range
    local block_start, block_end = find_block_range(bufnr, cursor_line)

    if not block_start or not block_end then
        return
    end

    -- Highlight the block lines
    for line = block_start - 1, block_end - 1 do
        vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
            end_line = line,
            end_col = 0,
            hl_group = config.highlight_group,
            hl_eol = true,
            priority = 100,
        })
    end

    -- Add indent guides if enabled
    if config.show_indent_guides then
        local lines = vim.api.nvim_buf_get_lines(bufnr, block_start - 1, block_end, false)
        local min_indent = math.huge

        -- Find minimum indent level in the block
        for _, line in ipairs(lines) do
            if not is_empty_line(line) then
                local indent = get_indent_level(line)
                if indent < min_indent then
                    min_indent = indent
                end
            end
        end

        -- Draw indent guides
        if min_indent > 0 and min_indent ~= math.huge then
            for i, line in ipairs(lines) do
                if not is_empty_line(line) then
                    local line_num = block_start - 1 + i - 1
                    -- Add indent guide at the block's indent level
                    vim.api.nvim_buf_set_extmark(bufnr, ns, line_num, min_indent - 1, {
                        virt_text = { { config.indent_char, config.indent_highlight } },
                        virt_text_pos = "overlay",
                        priority = 200,
                    })
                end
            end
        end
    end
end

-- Debounced highlight function
local function highlight_block_debounced()
    if timer then
        timer:stop()
    end

    timer = vim.defer_fn(function()
        highlight_block()
    end, config.debounce_ms)
end

-- Setup autocommands
local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("CurrentBlockHighlight", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        callback = highlight_block_debounced,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = group,
        callback = highlight_block,
    })

    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
        group = group,
        callback = function()
            clear_highlights(vim.api.nvim_get_current_buf())
        end,
    })
end

-- Setup function
function M.setup(opts)
    -- Merge user config with defaults
    config = vim.tbl_deep_extend("force", config, opts or {})

    -- Setup autocommands
    setup_autocmds()

    -- Create commands
    vim.api.nvim_create_user_command("CurrentBlockToggle", function()
        config.enabled = not config.enabled
        if not config.enabled then
            clear_highlights(vim.api.nvim_get_current_buf())
        else
            highlight_block()
        end
        print("Current block highlight: " .. (config.enabled and "enabled" or "disabled"))
    end, {})

    vim.api.nvim_create_user_command("CurrentBlockEnable", function()
        config.enabled = true
        highlight_block()
    end, {})

    vim.api.nvim_create_user_command("CurrentBlockDisable", function()
        config.enabled = false
        clear_highlights(vim.api.nvim_get_current_buf())
    end, {})
end

return M
