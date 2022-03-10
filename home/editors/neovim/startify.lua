local function formatDirs(files)
  local results = {}
  for _, file in ipairs(files) do
    table.insert(results, { line = file, path = file })
  end
  return results
end

local function gitModified()
  local files = vim.fn.systemlist("git ls-files -m 2>/dev/null")
  return formatDirs(files)
end

local function gitUntracked()
  local files = vim.fn.systemlist("git ls-files -o --exclude-standard 2>/dev/null")
  return formatDirs(files)
end

local function escapePattern(text)
  return text:gsub("([^%w])", "%%%1")
end

local function listProjects()
  local gitDirs = vim.fn.finddir(".git", vim.env.HOME .. "/dev/**4", -1)
  table.insert(gitDirs, 1, "/etc/nixos")
  return vim.fn.map(gitDirs, function(_, gitDir)
    local dir = gitDir:gsub(escapePattern(".git"), "")
    dir = dir == "" and "." or dir
    local line = dir:gsub(escapePattern(vim.env.HOME), "~")
    return {
      line = line,
      path = dir,
    } end
  )
end

vim.g.startify_commands = {
  {h = {"Vim Help", "help"}},
  {r = {"Vim Reference", "help reference"}},
}

vim.g.startify_lists = {
  { header = {"   Sessions"},      type = "sessions" },
  { header = {"   git modified"},  type = gitModified },
  { header = {"   git untracked"}, type = gitUntracked },
  { header = {"   Projects"},      type = listProjects },
  { header = {"   Recent files"},  type = "files" },
  { header = {"   Commands"},      type = "commands" },
}
