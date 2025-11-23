-- debug.lua
-- Configuración de DAP compatible con Windows y WSL (Linux)

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Debuggers específicos
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Detectar sistema operativo
    local is_windows = vim.fn.has 'win32' == 1

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve', -- Go
        'debugpy', -- Python
        'codelldb', -- C++ / C / Rust (IMPORTANTE PARA TI)
      },
    }

    -- Configuración de UI
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⸸',
          play = '▶',
          step_into = '⎆',
          step_over = '⭮',
          step_out = '⭯',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Iconos de Breakpoints
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = { Breakpoint = '🔴', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    -- Listeners para abrir/cerrar UI automáticamente
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -----------------------------------------------------------------------
    -- CONFIGURACIÓN GO
    -----------------------------------------------------------------------
    require('dap-go').setup {
      delve = {
        detached = not is_windows, -- En Windows debe ser false (attached), en Linux true
      },
    }

    -----------------------------------------------------------------------
    -- CONFIGURACIÓN PYTHON
    -----------------------------------------------------------------------
    -- Lógica para elegir el intérprete según el OS
    local python_path
    if is_windows then
      python_path = 'C:\\Users\\danis.DESKTOP-HQR1BPJ\\AppData\\Local\\Programs\\Python\\Python314\\python.exe'
    else
      -- EN LINUX/WSL: Usamos el Python interno que instala Mason.
      -- Este es el único que garantizamos que tiene 'debugpy' instalado.
      python_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'

      -- Si por casualidad Mason no lo ha instalado, usamos el del sistema como último recurso
      if vim.fn.filereadable(python_path) == 0 then
        python_path = '/usr/bin/python3'
      end
    end

    require('dap-python').setup(python_path)

    -- Configuraciones extra de Python para asegurar que funcione
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        console = 'integratedTerminal',
        pythonArgs = { '-Xfrozen_modules=off' }, -- Necesario para debugpy moderno
        pythonPath = function()
          local venv = os.getenv 'VIRTUAL_ENV'
          if venv then
            return venv .. '/bin/python'
          else
            return '/usr/bin/python3'
          end
        end,
      },
    }

    -----------------------------------------------------------------------
    -- CONFIGURACIÓN C++ / C / RUST (Añadida para ti)
    -----------------------------------------------------------------------
    -- Mason instala codelldb automáticamente, pero a veces hay que configurar el adaptador manualmente
    -- Si usas Mason, esto suele configurarse solo via mason-nvim-dap,
    -- pero aquí definimos la configuración de lanzamiento.
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }
    -- Usar la misma config para C y Rust
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
  end,
}
