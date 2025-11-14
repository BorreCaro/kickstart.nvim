return {
  'github/copilot.vim',
  event = 'InsertEnter',
  config = function()
    local opts = { noremap = true, silent = true }

    ---------------------------------------------------------------------------
    -- Insert mode: aceptar sugerencias con Ctrl-J
    -- (si no lo quieres, borra esta parte y pon vim.g.copilot_no_tab_map = false)
    ---------------------------------------------------------------------------
    vim.g.copilot_no_tab_map = true
    vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      silent = true,
      desc = 'Copilot accept suggestion',
    })

    ---------------------------------------------------------------------------
    -- Keymaps normales
    ---------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>ce', ':Copilot enable<CR>', opts)
    vim.keymap.set('n', '<leader>cd', ':Copilot disable<CR>', opts)
    vim.keymap.set('n', '<leader>cs', ':Copilot status<CR>', opts)
    vim.keymap.set('n', '<leader>cp', ':Copilot panel<CR>', opts)

    -- cc = quick check
    vim.keymap.set('n', '<leader>cc', function()
      local ok, enabled = pcall(function()
        return vim.b.copilot_enabled
      end)
      if ok and enabled == false then
        vim.notify('Copilot: disabled for this buffer', vim.log.levels.INFO)
      elseif ok and enabled == true then
        vim.notify('Copilot: enabled for this buffer', vim.log.levels.INFO)
      else
        vim.cmd 'Copilot status'
      end
    end, opts)

    ---------------------------------------------------------------------------
    -- which-key v3 group
    ---------------------------------------------------------------------------
    local wk_ok, wk = pcall(require, 'which-key')
    if wk_ok then
      wk.add {
        -- Grupo principal
        { '<leader>c', group = '[C] Copilot' },

        -- Comandos dentro del grupo
        { '<leader>ce', ':Copilot enable<CR>', desc = 'Enable Copilot' },
        { '<leader>cd', ':Copilot disable<CR>', desc = 'Disable Copilot' },
        { '<leader>cs', ':Copilot status<CR>', desc = 'Copilot status' },
        { '<leader>cp', ':Copilot panel<CR>', desc = 'Copilot panel' },
        { '<leader>cc', desc = 'Quick Copilot check' },
      }
    end

    ---------------------------------------------------------------------------
    -- Opcional: color visible de sugerencias si tu colorscheme no define el grupo
    ---------------------------------------------------------------------------
    pcall(function()
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', { fg = '#5c6ac4', italic = true })
    end)
  end,
}
