local M = {}

function M.list_visible_windows()
	local wins = vim.api.nvim_tabpage_list_wins(0)

	for _, w_id in ipairs(wins) do
		local config = vim.api.nvim_win_get_config(w_id)
		if config.hide == false then
			print(w_id, config.relative)
		end
	end
end

---
-- Gets the visible neighbors of a given window.
-- @param win_id The window ID to check. Use 0 for the current window.
-- @return A table with keys "up", "down", "left", "right", each containing a list of neighbor window IDs.
function M.get_visible_neighbours(win_id)
	local target_win_id = (win_id == 0) and vim.api.nvim_get_current_win() or win_id

	if not vim.api.nvim_win_is_valid(target_win_id) then
		return {}
	end

	local target_pos = vim.api.nvim_win_get_position(target_win_id)
	local target_height = vim.api.nvim_win_get_height(target_win_id)
	local target_width = vim.api.nvim_win_get_width(target_win_id)

	local target_top = target_pos[1]
	local target_bottom = target_pos[1] + target_height
	local target_left = target_pos[2]
	local target_right = target_pos[2] + target_width

	local neighbours = {
		up = {},
		down = {},
		left = {},
		right = {},
	}

	local wins = vim.api.nvim_tabpage_list_wins(0)
	for _, w_id in ipairs(wins) do
		if w_id ~= target_win_id and vim.api.nvim_win_is_valid(w_id) then
			local config = vim.api.nvim_win_get_config(w_id)
			if config.relative == "" then -- Not a floating window
				local pos = vim.api.nvim_win_get_position(w_id)
				local height = vim.api.nvim_win_get_height(w_id)
				local width = vim.api.nvim_win_get_width(w_id)

				local top = pos[1]
				local bottom = pos[1] + height
				local left = pos[2]
				local right = pos[2] + width

				if top - 1 == target_bottom then
					table.insert(neighbours.down, w_id)
				elseif bottom + 1 == target_top then
					table.insert(neighbours.up, w_id)
				end

				if left - 1 == target_right then
					table.insert(neighbours.right, w_id)
				elseif right + 1 == target_left then
					table.insert(neighbours.left, w_id)
				end
			end
		end
	end

	return neighbours
end

---
-- Resizes a window based on a direction and neighbors.
-- @param win_id The window ID to resize. Use 0 for the current window.
-- @param direction The direction to resize: "up", "down", "left", or "right".
function M.resize_window(win_id, direction)
	local target_win_id = (win_id == 0) and vim.api.nvim_get_current_win() or win_id
	if not vim.api.nvim_win_is_valid(target_win_id) then
		return
	end

	local neighbours = M.get_visible_neighbours(target_win_id)
	local resize_step = 2
	local original_win = vim.api.nvim_get_current_win()

	local function resize(win, cmd)
		if not vim.api.nvim_win_is_valid(win) then
			return
		end
		vim.api.nvim_set_current_win(win)
		vim.cmd(cmd)
		if vim.api.nvim_win_is_valid(original_win) then
			vim.api.nvim_set_current_win(original_win)
		end
	end

	if direction == "up" then
		local has_up = #neighbours.up > 0
		local has_down = #neighbours.down > 0

		if has_up and not has_down then
			-- Only neighbor above: increase size upward (shrink neighbor above)
			resize(neighbours.up[1], "resize -" .. resize_step)
		elseif has_up and has_down then
			-- Neighbors on both sides: up direction reduces target window size
			resize(target_win_id, "resize -" .. resize_step)
		else
			-- No neighbor above: shrink target window
			resize(target_win_id, "resize -" .. resize_step)
		end
	elseif direction == "down" then
		local has_down = #neighbours.down > 0
		local has_up = #neighbours.up > 0

		if has_down and not has_up then
			-- Only neighbor below: increase size downward (grow target)
			resize(target_win_id, "resize +" .. resize_step)
		elseif has_down and has_up then
			-- Neighbors on both sides: down direction increases target window size
			resize(target_win_id, "resize +" .. resize_step)
		else
			-- No neighbor below: shrink target window
			resize(target_win_id, "resize -" .. resize_step)
		end
	elseif direction == "left" then
		local has_left = #neighbours.left > 0
		local has_right = #neighbours.right > 0

		if has_left and not has_right then
			-- Only neighbor to left: increase size leftward (shrink left neighbor)
			resize(neighbours.left[1], "vertical resize -" .. resize_step)
		elseif has_left and has_right then
			-- Neighbors on both sides: left direction reduces target window size
			resize(target_win_id, "vertical resize -" .. resize_step)
		else
			-- No neighbor to left: shrink target window
			resize(target_win_id, "vertical resize -" .. resize_step)
		end
	elseif direction == "right" then
		local has_right = #neighbours.right > 0
		local has_left = #neighbours.left > 0

		if has_right and not has_left then
			-- Only neighbor to right: increase size rightward (grow target)
			resize(target_win_id, "vertical resize +" .. resize_step)
		elseif has_right and has_left then
			-- Neighbors on both sides: right direction increases target window size
			resize(target_win_id, "vertical resize +" .. resize_step)
		else
			-- No neighbor to right: shrink target window
			resize(target_win_id, "vertical resize -" .. resize_step)
		end
	end
end

function M.resize_left()
	M.resize_window(0, "left")
end

function M.resize_right()
	M.resize_window(0, "right")
end

function M.resize_up()
	M.resize_window(0, "up")
end

function M.resize_down()
	M.resize_window(0, "down")
end

-- Default keybindings
local default_keys = {
	{ "<C-Left>", function() require("simple-resizer").resize_left() end, desc = "Resize window left" },
	{ "<C-Right>", function() require("simple-resizer").resize_right() end, desc = "Resize window right" },
	{ "<C-Up>", function() require("simple-resizer").resize_up() end, desc = "Resize window up" },
	{ "<C-Down>", function() require("simple-resizer").resize_down() end, desc = "Resize window down" },
}

M.config = {
	-- Default configuration options
	create_commands = true, -- Set to false to disable user commands
	keys = default_keys, -- Set to false to disable, or provide custom keybindings
}

function M.setup(opts)
	-- Handle keys specially to allow false to disable defaults
	local keys = opts and opts.keys ~= nil and opts.keys or M.config.keys
	opts = opts or {}
	opts.keys = nil -- Remove keys from opts to avoid deep_extend issues

	M.config = vim.tbl_deep_extend("force", M.config, opts)
	M.config.keys = keys

	-- Create user commands if enabled
	if M.config.create_commands then
		vim.api.nvim_create_user_command('ResizeLeft', function()
			M.resize_left()
		end, { desc = 'Resize window left' })

		vim.api.nvim_create_user_command('ResizeRight', function()
			M.resize_right()
		end, { desc = 'Resize window right' })

		vim.api.nvim_create_user_command('ResizeUp', function()
			M.resize_up()
		end, { desc = 'Resize window up' })

		vim.api.nvim_create_user_command('ResizeDown', function()
			M.resize_down()
		end, { desc = 'Resize window down' })
	end

	-- Create keybindings if configured
	if M.config.keys and type(M.config.keys) == "table" then
		for _, keymap in ipairs(M.config.keys) do
			local key = keymap[1]
			local action = keymap[2]
			local mode = keymap.mode or "n"
			local desc = keymap.desc or ""

			-- Handle both function and string (command) actions
			if type(action) == "string" then
				vim.keymap.set(mode, key, action, { desc = desc, noremap = true, silent = true })
			else
				vim.keymap.set(mode, key, action, { desc = desc, noremap = true, silent = true })
			end
		end
	end
end

return M
