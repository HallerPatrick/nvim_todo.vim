local api = vim.api

-- Are always overwritten so should not be a problem
-- Even though I dont like it...
local result
local todo_buf, win



-- Create over floating buffer and return the buf
-- to write the todo lines to
-- Mainly taken from: https://www.2n.pl/blog/how-to-write-neovim-plugins-in-lua
local function show_window()
    todo_buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

    api.nvim_buf_set_option(todo_buf, 'bufhidden', 'wipe')

    -- get dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- calculate our floating window size
    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.8)

    -- and its starting position
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- set some options
    local opts = {
      style = "minimal",
      relative = "editor",
      width = win_width,
      height = win_height,
      row = row,
      col = col
    }

    local border_opts = {
      style = "minimal",
      relative = "editor",
      width = win_width + 2,
      height = win_height + 2,
      row = row - 1,
      col = col - 1
    }

    local border_buf = api.nvim_create_buf(false, true)

    local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    for i=1, win_height do
      table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

    api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    -- and finally create it with buffer attached
    local border_win = api.nvim_open_win(border_buf, true, border_opts)
    win = api.nvim_open_win(todo_buf, true, opts)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

end

local function show_todo_list()
    show_window()

    result = vim.fn.systemlist('rg "TODO" --line-number')

    local d_result = {}

    -- with small indentation results will look better
    for k,v in pairs(result) do
      d_result[k] = '  '..result[k]
    end

    api.nvim_buf_set_lines(todo_buf, 0, -1, false, d_result)

    -- Set Key Map for Enter to open file under line
    -- TODO: This can probably be writen more or less in pure lua
    api.nvim_buf_set_keymap(
        todo_buf, 'n', '<CR>', ":lua require('nvim_todo').open_line_buffer() <CR>",
        { nowait = true, noremap = true, silent = true }
    )
end

-- Weird function to get line number and filename from line
local function split_line(line)
    local line_parts = {}
    local index = 1
    local cur_pos = 1
    for i = 1, string.len(line) do
        if string.sub(line, i, i) == ":" then
            -- The last part is the found string of todo
            if index == 3 then
                break
            else
                line_parts[index] = string.sub(line, cur_pos, i)
                cur_pos = i
                index = index + 1
            end
        end
    end
    return line_parts
end

local function open_line_buffer()

    local pos = api.nvim_win_get_cursor(win)
    local row = pos[1]
    local line = result[row]

    -- Remove Colons
    local splitted_line = split_line(line)
    local filename = string.gsub(splitted_line[1], ":", "")
    local line_no = string.gsub(splitted_line[2], ":", "")
    local cmd = ":e +" ..line_no .. " " ..filename

    -- Close window and open new buffer with target file
    api.nvim_win_close(win, true)
    api.nvim_command(cmd)
end

return {
    show = show_todo_list,
    open_line_buffer = open_line_buffer
}

