return {
  {
    'preservim/vimux',
    config = function()
      -- === LÓGICA DEL RUNNER INTELIGENTE ===
      local function run_current_file()
        -- 1. Guardar el archivo antes de ejecutar
        vim.cmd 'write'

        -- 2. Detectar variables del entorno
        local file = vim.fn.expand '%'
        local file_no_ext = vim.fn.expand '%:r'
        local ft = vim.bo.filetype
        local is_windows = vim.fn.has 'win32' == 1
        local cmd = ''

        -- 3. Definir el comando según el lenguaje y el sistema operativo
        if ft == 'python' then
          local py_cmd = is_windows and 'python' or 'python3'
          cmd = py_cmd .. ' ' .. file
        elseif ft == 'cpp' then
          if is_windows then
            -- Windows: Compila a .exe y ejecuta
            cmd = 'g++ ' .. file .. ' -o ' .. file_no_ext .. '.exe && ' .. file_no_ext .. '.exe'
          else
            -- Linux: Compila, ejecuta y limpia el binario
            cmd = 'g++ -g ' .. file .. ' -o ' .. file_no_ext .. ' && ./' .. file_no_ext .. ' && rm ' .. file_no_ext
          end
        elseif ft == 'c' then
          if is_windows then
            cmd = 'gcc ' .. file .. ' -o ' .. file_no_ext .. '.exe && ' .. file_no_ext .. '.exe'
          else
            cmd = 'gcc -g ' .. file .. ' -o ' .. file_no_ext .. ' && ./' .. file_no_ext .. ' && rm ' .. file_no_ext
          end
        elseif ft == 'javascript' then
          cmd = 'node ' .. file
        elseif ft == 'typescript' then
          cmd = 'ts-node ' .. file
        elseif ft == 'go' then
          cmd = 'go run ' .. file
        elseif ft == 'rust' then
          cmd = 'cargo run'
        elseif ft == 'java' then
          cmd = 'javac ' .. file .. ' && java ' .. file_no_ext
        else
          print('⚠️ Lenguaje no configurado: ' .. ft)
          return
        end

        -- 4. Decidir DÓNDE ejecutar
        -- Si estamos en Windows O si NO estamos dentro de una sesión de Tmux:
        if is_windows or not os.getenv 'TMUX' then
          -- Opción A: Terminal nativa de Neovim (Split vertical a la derecha)
          vim.cmd 'vsplit'
          vim.cmd('term ' .. cmd)
          vim.cmd 'startinsert' -- Entrar en modo escritura automáticamente
        else
          -- Opción B: Panel de Tmux (usando Vimux)
          vim.fn.VimuxRunCommand(cmd)
        end
      end

      -- === KEYMAPS ===
      -- Ejecutar código (Smart: elige Tmux o Terminal nativa según corresponda)
      vim.keymap.set('n', '<leader>r', run_current_file, { desc = 'Ejecutar código (Smart Runner)' })

      -- Comandos específicos de Tmux (solo funcionarán si usas Vimux)
      vim.keymap.set('n', '<leader>rl', ':VimuxRunLastCommand<CR>', { desc = 'Repetir último comando (Tmux)' })
      vim.keymap.set('n', '<leader>ri', ':VimuxInspectRunner<CR>', { desc = 'Ir al panel de Tmux' })
      vim.keymap.set('n', '<leader>rc', ':VimuxCloseRunner<CR>', { desc = 'Cerrar panel de Tmux' })
    end,
  },
}
