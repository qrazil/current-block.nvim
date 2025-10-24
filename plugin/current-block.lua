-- plugin/current-block.lua
if vim.fn.has("nvim-0.8.0") == 0 then
    vim.api.nvim_err_writeln("current-block.nvim requires at least nvim-0.8.0")
    return
end

-- Prevent loading file twice
if vim.g.loaded_current_block == 1 then
    return
end
vim.g.loaded_current_block = 1
