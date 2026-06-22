local M = {}

M.root_markers = {
	"pyrightconfig.json",
	"pyproject.toml",
	"uv.lock",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	".git",
}

local function first_executable(root, relpaths)
	for _, relpath in ipairs(relpaths) do
		local path = vim.fs.joinpath(root, relpath)
		if vim.fn.executable(path) == 1 then
			return path
		end
	end
end

function M.find_python_path(startpath)
	local search_from = startpath or vim.uv.cwd()
	if not search_from or search_from == "" then
		return nil
	end

	local venv_dir = vim.fs.find({ ".venv", "venv" }, {
		path = search_from,
		upward = true,
		type = "directory",
		limit = 1,
	})[1]

	if venv_dir then
		local python_path = first_executable(venv_dir, { "bin/python", "Scripts/python.exe" })
		if python_path then
			return python_path
		end
	end

	if vim.env.VIRTUAL_ENV then
		local active_python = first_executable(vim.env.VIRTUAL_ENV, { "bin/python", "Scripts/python.exe" })
		if active_python then
			return active_python
		end
	end

	for _, executable in ipairs({ "python3", "python" }) do
		local python_path = vim.fn.exepath(executable)
		if python_path ~= "" and not python_path:match("WindowsApps[\\/]python%.exe$") then
			return python_path
		end
	end

	return nil
end

function M.set_python_path(settings, python_path)
	if not python_path or python_path == "" then
		return settings
	end

	settings = settings or {}
	settings.python = settings.python or {}
	settings.python.pythonPath = python_path

	return settings
end

function M.with_python_path(settings, python_path)
	if not python_path or python_path == "" then
		return settings
	end

	return M.set_python_path(vim.deepcopy(settings or {}), python_path)
end

function M.update_python_path(client, python_path)
	if not python_path or python_path == "" then
		return
	end

	local runtime_path = client.settings and client.settings.python and client.settings.python.pythonPath
	local current_path = client.config.settings
		and client.config.settings.python
		and client.config.settings.python.pythonPath

	if runtime_path == python_path and current_path == python_path then
		return
	end

	client.settings = M.with_python_path(client.settings, python_path)
	client.config.settings = M.with_python_path(client.config.settings, python_path)

	if client.workspace_did_change_configuration then
		client.workspace_did_change_configuration(client.settings)
	else
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end
end

function M.opts()
	return {
		root_markers = M.root_markers,
		before_init = function(_, config)
			config.settings = M.set_python_path(config.settings, M.find_python_path(config.root_dir))
		end,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					diagnosticMode = "workspace",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					exclude = { "venv", ".venv", "__pycache__", "*.pyc" },
				},
			},
		},
	}
end

function M.on_attach(args, client)
	local bufname = vim.api.nvim_buf_get_name(args.buf)
	local startpath = bufname ~= "" and vim.fs.dirname(bufname) or client.config.root_dir

	M.update_python_path(client, M.find_python_path(startpath))
end

return M
