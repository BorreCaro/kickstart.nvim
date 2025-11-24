return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = { 'Silicon' },
  -- Esto hace que lazy.nvim cargue el plugin cuando uses <leader>ns
  keys = {
    { '<leader>ns', mode = 'n', desc = 'Screenshot whole file to clipboard' },
    { '<leader>sf', mode = 'v', desc = 'Save code screenshot as file' },
    { '<leader>sc', mode = 'v', desc = 'Copy code screenshot to clipboard' },
    { '<leader>ss', mode = 'v', desc = 'Create code screenshot' },
  },
  main = 'nvim-silicon',
  config = function()
    local ok, silicon = pcall(require, 'nvim-silicon')
    if not ok then
      vim.notify('nvim-silicon not found', vim.log.levels.ERROR)
      return
    end

    silicon.setup {
      disable_defaults = false,
      debug = false,
      theme = 'OneHalfDark',
      wslclipboard = 'auto',
      wslclipboardcopy = 'delete',
    }

    -- Visual: guardar como archivo
    vim.keymap.set('v', '<leader>sf', function()
      silicon.file()
    end, { desc = 'Save code screenshot as file' })

    -- Visual: copiar al clipboard
    vim.keymap.set('v', '<leader>sc', function()
      silicon.clip()
    end, { desc = 'Copy code screenshot to clipboard' })

    -- Visual: capturar y mostrar
    vim.keymap.set('v', '<leader>ss', function()
      silicon.shoot()
    end, { desc = 'Create code screenshot' })

    -- Normal: screenshot de todo el archivo -> copiar al clipboard
    vim.keymap.set('n', '<leader>ns', function()
      -- El LSP (LuaLS) puede decir que clip() no acepta argumentos.
      -- Esto suprime ese warning y sigue llamando a la función real.
      ---@diagnostic disable-next-line
      silicon.clip {
        from = 1,
        to = vim.fn.line '$',
      }
    end, { desc = 'Screenshot whole file to clipboard' })
  end,
}
