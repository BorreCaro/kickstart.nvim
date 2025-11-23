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
        'codelldb', -- C++ / C / Rust
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
        detached = not is_windows,
      },
    }

    -----------------------------------------------------------------------
    -- CONFIGURACIÓN PYTHON
    -----------------------------------------------------------------------
    local python_path
    if is_windows then
      python_path = 'C:\\Users\\danis.DESKTOP-HQR1BPJ\\AppData\\Local\\Programs\\Python\\Python314\\python.exe'
    else
      -- Linux/WSL: Python interno de Mason
      python_path = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'
      if vim.fn.filereadable(python_path) == 0 then
        python_path = '/usr/bin/python3'
      end
    end

    require('dap-python').setup(python_path)

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        console = 'integratedTerminal',
        pythonArgs = { '-Xfrozen_modules=off' },
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
    -- CONFIGURACIÓN C++ / C / RUST (Actualizada)
    -----------------------------------------------------------------------
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'codelldb',
        request = 'launch',
        -- Aquí está la magia: Calcula automáticamente ruta/bin/archivo
        program = function()
          local is_win = vim.fn.has 'win32' == 1
          local sep = is_win and '\\' or '/'
          local ext = is_win and '.exe' or ''
          local cwd = vim.fn.getcwd()
          local file_name = vim.fn.expand '%:t:r' -- Nombre archivo sin extensión

          -- Construye: C:\Proyecto\bin\main.exe o /home/user/proyecto/bin/main
          local default_path = cwd .. sep .. 'bin' .. sep .. file_name .. ext

          return vim.fn.input('Path to executable: ', default_path, 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    -- Reutilizamos la config para C y Rust
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
  end,
}
