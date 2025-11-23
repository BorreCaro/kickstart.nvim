return {
  'xiyaowong/transparent.nvim',
  lazy = false,
  config = function()
    require('transparent').setup {
      -- Opcional: ajusta qué grupos quieres limpiar
      extra_groups = {
        'NormalFloat', -- ventanas flotantes
        'NvimTreeNormal', -- si usas NvimTree
      },
    }
  end,
}
