function ftplugin ()
    -- Only do this when not done yet for this buffer
    if vim.b.did_ftplugin ~= nil then
      return
    end
    vim.b.did_ftplugin = 1
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
end

ftplugin()

