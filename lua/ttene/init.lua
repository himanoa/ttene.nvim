---@class tteneOpts
---@field cmd "mplayer" | "afplay"
---@field voices_dir string
local default_config = require("ttene.config")
local path_sep = vim.fn.has("win32") == 1 and "\\" or "/"
default_config.voices_dir = table.concat({vim.fn.stdpath("data"), "ttene"}, path_sep)

---@class ttene
---@field private cmd "mplayer" | "afplay"
---@field private voices_dir string
---@field private voices string[]
---@field private setup_voices fun(self: ttene): boolean
---@field pick_voice fun(): string?
---@field play fun()
---@field setup fun(opts: tteneOpts)
local M = {}

local uv = vim.uv or vim.loop

---@param path string
---@param mode integer
---@return boolean|nil success
---@return nil|string err
local function mkdir_p(path, mode)
  local success, err = uv.fs_mkdir(path, mode)
  if success then
    return true
  elseif err and string.match(err, "^EEXIST") then
    return true
  elseif err and string.match(err, "^ENOENT") then
    success, err = mkdir_p(table.concat({path, ".."}, path_sep), mode)
    if not success then return nil, err end
    return uv.fs_mkdir(path, mode)
  end
  return nil, err
end

---@private
function M:setup_voices()
  if not self.voices then
    local dirp = uv.fs_opendir(self.voices_dir, 100) -- up to limit iterations to 100 entries
    if not dirp then
      return false
    end
    M.voices = vim.iter(uv.fs_readdir(dirp)):filter(function(v)
      return v.type == "file"
    end):map(function(v)
      return M.voices_dir .. path_sep .. v.name
    end):totable()
  end
  return true
end

function M.pick_voice()
  if not M.loaded then
    vim.notify("please call setup()", vim.log.levels.INFO, {title = "ttene"})
    return nil
  end
  math.randomseed( os.time() )
  local ret = M.voices[math.random(#M.voices)]
  return ret ~= "" and ret or nil
end

function M.play()
  if not M.loaded then
    vim.notify("please call setup()", vim.log.levels.INFO, {title = "ttene"})
    return
  end
  local voice_file = M.pick_voice()
  if not voice_file then
    vim.notify("no voices installed. see README.md", vim.log.levels.ERROR, {title = "ttene"})
    return
  end

  vim.system({M.cmd, voice_file},
    {text = false, stdin=nil, stdout=false, stderr=false},
    function() end)
end

function M.setup(opts)
  if M.loaded then
    vim.notify("plugin is already loaded", vim.log.levels.INFO, {title = "ttene"})
    return
  end
  opts = opts or {}
  opts = vim.tbl_deep_extend("force", {}, default_config, opts)

  if not vim.fn.executable(opts.cmd) == 1 then
    vim.notify(opts.cmd .. " is not found or not executable", vim.log.levels.INFO, {title = "ttene"})
    return
  end

  M.voices_dir = opts.voices_dir
  M.cmd = opts.cmd

  local mode = 0x1ED -- S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH (0755)
  local success, err = mkdir_p(M.voices_dir, mode)
  if not success then
    vim.notify("failed to create voices directory or directory is not found: " .. (err or ""), vim.log.levels.ERROR, {title = "ttene"})
    return
  end

  if not M:setup_voices() then
    vim.notify("failed to list up voice files", vim.log.levels.ERROR, {title = "ttene"})
    return
  end

  local augroup = vim.api.nvim_create_augroup("ttene", {clear = true})
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    callback = function(args)
      local leave_augroup = vim.api.nvim_create_augroup("ttene-leave", {clear = true})
      vim.keymap.set("i", "<CR>", M.play, {buffer = args.buffer})
      vim.api.nvim_create_autocmd("InsertLeave", {
        group = leave_augroup,
        buffer = args.buffer,
        callback = function ()
          vim.api.nvim_clear_autocmds({group=leave_augroup})
          M.play()
        end
      })
    end
  })

  M.loaded = true
end

return M
