vim.filetype.add({
  extension = {
    ncl = "nickel",
    nickel = "nickel",
    vert = "glsl",
    tesc = "glsl",
    tese = "glsl",
    glsl = "glsl",
    geom = "glsl",
    frag = "glsl",
    comp = "glsl",
    rgen = "glsl",
    rmiss = "glsl",
    rchit = "glsl",
    rahit = "glsl",
    rint = "glsl",
    rcall = "glsl",
  },
  pattern = {
    [".env.*"] = "sh",
    [".*"] = function(path, bufnr)
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)[1]
      if first_line ~= nil and first_line:match("^#!.*nix%-shell") ~= nil then
        local second_line = vim.api.nvim_buf_get_lines(bufnr, 1, 2, true)[1]
        local command = second_line:match("^#!.*nix%-shell .*%-i ([%a%d]*)")
        if command == nil then
          return nil
        elseif command == "sh" or command == "bash" then
          return "bash"
        elseif command == "node" then
          return "javascript"
        elseif command == "runhaskell" then
          return "haskell"
        elseif command == "ghci" then
          return "haskell"
        end

        return command
      end

      return nil
    end
  },
})
