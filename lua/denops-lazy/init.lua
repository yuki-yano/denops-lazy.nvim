local M = {}

---@class denops-lazy.Opts
---@field public wait_load? boolean # default: true
---@field public wait_server? boolean # default: true
---@field public wait_server_delay? number # default: 10
---@field public wait_server_retry_limit? number # default:100

---@type denops-lazy.Opts
local default_opts = {
  wait_load = true,
  wait_server = true,
  wait_server_delay = 10,
  wait_server_retry_limit = 100,
}

---@param opts denops-lazy.Opts
M.setup = function(opts)
  default_opts = vim.tbl_deep_extend('force', default_opts, opts or {})
end

---@param opts denops-lazy.Opts
local function wait_server(opts)
  local once = false
  for _ = 1, opts.wait_server_retry_limit do
    if vim.fn['denops#server#status']() == 'running' then
      return
    end
    if not once then
      require('lazy').load({ plugins = 'denops.vim' })
      vim.fn['denops#server#start']()
      once = true
    end
    vim.wait(opts.wait_server_delay)
  end
end

---@param plugin_name string
---@param opts? denops-lazy.Opts
M.load = function(plugin_name, opts)
  require('lazy').load({ plugins = plugin_name })

  ---@type denops-lazy.Opts
  opts = vim.tbl_extend('force', default_opts, opts or {})

  local plugins = require('lazy').plugins()
  local plugin = nil
  for _, p in ipairs(plugins) do
    if p.name == plugin_name then
      plugin = p
      break
    end
  end

  if not plugin or vim.fn.isdirectory(plugin.dir .. '/' .. 'denops') == 0 then
    return
  end

  local denops_plugins = vim.fn.globpath(plugin.dir, 'denops/*/main.ts', true, true)

  if not #denops_plugins == 0 then
    if opts.wait_server then
      wait_server(opts)
    end
  end

  if not vim.fn['denops#server#status']() == 'running' then
    return
  end

  for _, denops_plugin in ipairs(denops_plugins) do
    local denops_plugin_name = vim.fn.fnamemodify(denops_plugin, ':h:t')

    if vim.fn['denops#plugin#is_loaded'](denops_plugin_name) == 0 then
      pcall(vim.fn['denops#plugin#load'], denops_plugin_name, denops_plugin)
      if opts.wait_load then
        vim.fn['denops#plugin#wait'](denops_plugin_name)
      end
    end
  end
end

return M
