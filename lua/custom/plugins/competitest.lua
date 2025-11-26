return {
  {
    'xeluxee/competitest.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    config = function()
      require('competitest').setup {
        host = '0.0.0.0',
        port = 10042,
        -- Configuración del runner (ejemplo para C++)
        compile_command = {
          cpp = { exec = 'g++', args = { '$(FNAME)', '-o', '$(FNOEXT)' } },
          rust = { exec = 'rustc', args = { '$(FNAME)' } }, -- Ya que usas Rust
        },
        run_command = {
          cpp = { exec = './$(FNOEXT)' },
          rust = { exec = './$(FNOEXT)' },
        },
        runner_ui = {
          interface = 'popup',
        },
        -- Plantillas para nuevos archivos
        template_file = {
          cpp = '~/source/comp/templates/template.cpp',
          rust = '~/source/comp/templates/template.rs',
        },
      }
    end,
    keys = {
      { '<leader>pr', '<cmd>CompetiTest run<cr>', desc = 'Correr Casos de Prueba' },
      { '<leader>pa', '<cmd>CompetiTest add_testcase<cr>', desc = 'Agregar Caso Manual' },
      { '<leader>pe', '<cmd>CompetiTest edit_testcase<cr>', desc = 'Editar Casos' },
      { '<leader>pi', '<cmd>CompetiTest receive problem<cr>', desc = 'Descargar Problema (Integration)' },
    },
  },
}
