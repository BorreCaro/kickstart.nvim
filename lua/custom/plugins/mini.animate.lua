return {
  'karb94/neoscroll.nvim',
  config = function()
    require('neoscroll').setup {
      -- Una función de atenuación cuadrática se siente más rápida
      easing_function = 'quadratic',
      hide_cursor = true, -- Ocultar cursor al hacer scroll aumenta FPS percibidos
      stop_eof = true, -- Parar al final del archivo
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.8, -- Reduce esto para hacerlo más rápido (menos lag)
    }
  end,
}
