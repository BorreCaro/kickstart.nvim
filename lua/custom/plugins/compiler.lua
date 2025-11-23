local function get_runner_commands(lang)
  -- Verifica si el sistema operativo host es Windows. Si no, asumimos Linux/WSL (Bash).
  local is_windows = vim.fn.has 'win32' == 1

  -- Directorios de salida (Linux usa / y Windows usa \)
  local dir_sep = is_windows and '\\' or '/'
  local output_dir = 'exes' .. dir_sep

  local linux_run_prefix = './'
  local win_run_prefix = ''
  local win_exe_suffix = '.exe'

  local create_dir_cmd = is_windows and 'mkdir exes 2>nul || echo. &&' or 'mkdir -p exes &&'
  local run_file = function(fileNameWithoutExt, prefix, suffix)
    return prefix .. output_dir .. fileNameWithoutExt .. suffix
  end

  local cmds = {
    ['rust'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'rustc $fileName -o bin' .. dir_sep .. '$fileNameWithoutExt' .. win_exe_suffix .. ' &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'rustc $fileName -o ' .. output_dir .. '$fileNameWithoutExt &&',
        run_file('$fileNameWithoutExt', linux_run_prefix, ''),
      },
    },
    ['c'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'gcc $fileName -o bin' .. dir_sep .. '$fileNameWithoutExt' .. win_exe_suffix .. ' &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'gcc $fileName -o ' .. output_dir .. '$fileNameWithoutExt &&',
        run_file('$fileNameWithoutExt', linux_run_prefix, ''),
      },
    },
    ['cpp'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'g++ -g $fileName -o bin' .. dir_sep .. '$fileNameWithoutExt' .. win_exe_suffix .. ' &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'g++ -g $fileName -o ' .. output_dir .. '$fileNameWithoutExt &&',
        run_file('$fileNameWithoutExt', linux_run_prefix, ''),
      },
    },
    ['go'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'go build -o bin' .. dir_sep .. '$fileNameWithoutExt' .. win_exe_suffix .. ' &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'go build -o ' .. output_dir .. '$fileNameWithoutExt &&',
        run_file('$fileNameWithoutExt', linux_run_prefix, ''),
      },
    },
    ['java'] = { -- Java es casi universal, solo cambia el separador de directorios en javac
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'javac $fileName -d bin &&',
        'java -cp exes $fileNameWithoutExt',
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'javac $fileName -d exes &&',
        'java -cp exes $fileNameWithoutExt',
      },
    },
    ['zig'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'zig build-exe $fileName -femit-bin=bin' .. dir_sep .. '$fileNameWithoutExt' .. win_exe_suffix .. ' &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'cd $dir &&',
        create_dir_cmd,
        'zig build-exe $fileName -femit-bin=' .. output_dir .. '$fileNameWithoutExt &&',
        run_file('$fileNameWithoutExt', linux_run_prefix, ''),
      },
    },
    ['cs'] = {
      win = {
        'cd $dir &&',
        create_dir_cmd,
        'csc $fileName /out:bin\\$fileNameWithoutExt.exe &&',
        run_file('$fileNameWithoutExt', win_run_prefix, win_exe_suffix),
      },
      linux = {
        'echo "Usando dotnet CLI en Linux..." &&',
        'dotnet run $fileName', -- El enfoque moderno en Linux/WSL es usar `dotnet run`
      },
    },
  }

  -- Retorna el conjunto de comandos específicos para el SO actual
  if cmds[lang] then
    return is_windows and cmds[lang].win or cmds[lang].linux
  end

  return nil
end

return {
  {
    'CRAG666/code_runner.nvim',
    config = function()
      -- 1. Runtimes que usan el mismo comando en ambos SOs (pero deben estar instalados)
      local filetype_map = {
        python = 'py -u', -- py -u es más universal que python3 -u
        javascript = 'node',
        typescript = 'ts-node',
      }

      -- 2. Agrega los lenguajes compilados con lógica condicional
      filetype_map.c = get_runner_commands 'c'
      filetype_map.cpp = get_runner_commands 'cpp'
      filetype_map.rust = get_runner_commands 'rust'
      filetype_map.go = get_runner_commands 'go'
      filetype_map.java = get_runner_commands 'java'
      filetype_map.zig = get_runner_commands 'zig'
      filetype_map.cs = get_runner_commands 'cs'

      require('code_runner').setup {
        filetype = filetype_map,
      }

      -- Keymaps (se mantienen iguales)
      vim.keymap.set('n', '<F6>', ':RunCode<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>r', ':RunCode<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rf', ':RunFile<CR>', { noremap = true, silent = false })
      vim.keymap.set('n', '<leader>rc', ':RunClose<CR>', { noremap = true, silent = false })
    end,
  },
}
