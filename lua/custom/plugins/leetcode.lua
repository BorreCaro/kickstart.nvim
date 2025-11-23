return {
  'kawre/leetcode.nvim',
  build = ':TSUpdate html', -- Actualiza el parser html para las descripciones
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    -- Lenguaje por defecto al iniciar (puedes cambiarlo dentro de nvim)
    lang = 'cpp',

    -- Forzamos el uso de Telescope
    picker = { provider = 'telescope' },

    -- Argumento para lanzar el plugin desde terminal
    arg = 'leetcode.nvim',

    -- Directorios donde se guarda tu caché y código
    storage = {
      home = vim.fn.stdpath 'data' .. '/leetcode',
      cache = vim.fn.stdpath 'cache' .. '/leetcode',
    },

    -- Opcional: Si usas Python a veces, inyección automática de imports
    injector = {
      ['python3'] = {
        imports = { 'from typing import List, Optional' },
      },
    },
  },
}
