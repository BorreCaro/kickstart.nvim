return {
  {
    'preservim/vimux',
    config = function()
      -- === Variables y Utilidades ===
      local function get_vars()
        local is_win = vim.fn.has 'win32' == 1
        return {
          file = vim.fn.expand '%', -- Ej: src/main.cpp
          name = vim.fn.expand '%:t:r', -- Ej: main
          ft = vim.bo.filetype,
          is_windows = is_win,
          mkdir = is_win and 'if not exist bin mkdir bin' or 'mkdir -p bin',
        }
      end

      -- Estrategia 1: RUN (Ejecución normal, se queda abierta para interactuar)
      local function execute_run(cmd)
        local is_windows = vim.fn.has 'win32' == 1
        if is_windows or not os.getenv 'TMUX' then
          vim.cmd 'vsplit'
          vim.cmd('term ' .. cmd)
          vim.cmd 'startinsert'
        else
          vim.fn.VimuxRunCommand(cmd)
        end
      end

      -- Estrategia 2: BUILD (Compilación, se cierra sola si todo sale bien)
      local function execute_build(cmd)
        local is_windows = vim.fn.has 'win32' == 1

        if is_windows or not os.getenv 'TMUX' then
          -- === MODO NATIVO (Windows/Neovim Terminal) ===
          vim.cmd 'vsplit'
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_win_set_buf(win, buf)

          -- Usamos termopen para tener "callbacks"
          vim.fn.termopen(cmd, {
            on_exit = function(job_id, exit_code, event)
              if exit_code == 0 then
                -- ÉXITO: Esperar 1 segundo y cerrar la ventana
                vim.defer_fn(function()
                  if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                    print '✅ Build Exitoso'
                  end
                end, 1000)
              else
                -- ERROR: Mantener abierta y avisar
                print '❌ Error en la Build'
              end
            end,
          })
          -- Scroll al final para ver output
          vim.cmd 'norm G'
        else
          -- === MODO TMUX ===
          -- Truco de Bash: (comando) && echo OK && sleep 1 && exit
          -- Si falla, el && corta la cadena y el 'exit' nunca ocurre (se queda abierta)
          local tmux_cmd = '(' .. cmd .. ") && echo '\n✅ Build OK - Cerrando...' && sleep 1 && exit"
          vim.fn.VimuxRunCommand(tmux_cmd)
        end
      end

      -- === 1. FUNCIÓN RUN ===
      local function run_current_file()
        vim.cmd 'write'
        local v = get_vars()
        local cmd = ''
        local join = ' && '

        if v.ft == 'python' then
          cmd = (v.is_windows and 'python ' or 'python3 ') .. v.file
        elseif v.ft == 'javascript' then
          cmd = 'node ' .. v.file
        elseif v.ft == 'typescript' then
          cmd = 'ts-node ' .. v.file
        elseif v.ft == 'cpp' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'g++ ' .. v.file .. ' -o bin\\' .. v.name .. '.exe' .. join .. 'bin\\' .. v.name .. '.exe'
          else
            cmd = v.mkdir .. join .. 'g++ -g ' .. v.file .. ' -o bin/' .. v.name .. join .. './bin/' .. v.name
          end
        elseif v.ft == 'c' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'gcc ' .. v.file .. ' -o bin\\' .. v.name .. '.exe' .. join .. 'bin\\' .. v.name .. '.exe'
          else
            cmd = v.mkdir .. join .. 'gcc -g ' .. v.file .. ' -o bin/' .. v.name .. join .. './bin/' .. v.name
          end
        elseif v.ft == 'go' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'go build -o bin\\' .. v.name .. '.exe ' .. v.file .. join .. 'bin\\' .. v.name .. '.exe'
          else
            cmd = v.mkdir .. join .. 'go build -o bin/' .. v.name .. ' ' .. v.file .. join .. './bin/' .. v.name
          end
        elseif v.ft == 'rust' then
          cmd = 'cargo run'
        elseif v.ft == 'java' then
          cmd = v.mkdir .. join .. 'javac -d bin ' .. v.file .. join .. 'java -cp bin ' .. v.name
        else
          print('⚠️ Run no configurado para: ' .. v.ft)
          return
        end

        execute_run(cmd)
      end

      -- === 2. FUNCIÓN BUILD (Autocierre) ===
      local function build_current_file()
        vim.cmd 'write'
        local v = get_vars()
        local cmd = ''
        local join = ' && '

        if v.ft == 'python' or v.ft == 'javascript' or v.ft == 'typescript' then
          print('ℹ️ ' .. v.ft .. ' no necesita build.')
          return
        elseif v.ft == 'cpp' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'g++ ' .. v.file .. ' -o bin\\' .. v.name .. '.exe'
          else
            cmd = v.mkdir .. join .. 'g++ -g ' .. v.file .. ' -o bin/' .. v.name
          end
        elseif v.ft == 'c' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'gcc ' .. v.file .. ' -o bin\\' .. v.name .. '.exe'
          else
            cmd = v.mkdir .. join .. 'gcc -g ' .. v.file .. ' -o bin/' .. v.name
          end
        elseif v.ft == 'go' then
          if v.is_windows then
            cmd = v.mkdir .. join .. 'go build -o bin\\' .. v.name .. '.exe ' .. v.file
          else
            cmd = v.mkdir .. join .. 'go build -o bin/' .. v.name .. ' ' .. v.file
          end
        elseif v.ft == 'java' then
          cmd = v.mkdir .. join .. 'javac -d bin ' .. v.file
        elseif v.ft == 'rust' then
          cmd = 'cargo build'
        else
          print('⚠️ Build no configurado para: ' .. v.ft)
          return
        end

        execute_build(cmd)
      end

      -- === KEYMAPS ===
      vim.keymap.set('n', '<leader>r', run_current_file, { desc = 'Ejecutar Código' })
      vim.keymap.set('n', '<leader>rb', build_current_file, { desc = 'Compilar (Build)' })

      -- Utilidades Tmux
      vim.keymap.set('n', '<leader>rl', ':VimuxRunLastCommand<CR>', { desc = 'Repetir último comando' })
      vim.keymap.set('n', '<leader>ri', ':VimuxInspectRunner<CR>', { desc = 'Ir al panel de Tmux' })
      vim.keymap.set('n', '<leader>rc', ':VimuxCloseRunner<CR>', { desc = 'Cerrar panel de Tmux' })
    end,
  },
}
