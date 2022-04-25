local dap = require("dap")

local function pwd() return io.popen("pwd"):lines()() end

dap.adapters.netcoredbg = {
  type = "executable",
  command = "netcoredbg",
  args = {
    "--interpreter=vscode",
    string.format("--engineLogging=%s/netcoredbg.engine.log", XDG_CACHE_HOME),
    string.format("--log=%s/netcoredbg.log", XDG_CACHE_HOME),
  },
}

dap.configurations.cs = {
  {
    type = "netcoredbg",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      local dll = io.popen("find bin/Debug/ -maxdepth 2 -name \"*.dll\"")
      return pwd() .. "/" .. dll:lines()()
    end,
    stopAtEntry = true,
  },
}

local dapui = require("dapui")
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

require("nvim-dap-virtual-text").setup()
