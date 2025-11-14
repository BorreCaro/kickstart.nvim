return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},
  config = function(_, opts)
    local npairs = require 'nvim-autopairs'
    local Rule = require 'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'

    -- Inicializar con las opciones de Lazy/Kickstart
    npairs.setup(opts)

    -- Regla mejorada para < > en HTML/JSX
    npairs.add_rule(Rule('<', '>', {
        'html',
        'xml',
        'javascriptreact',
        'typescriptreact',
        'astro',
        'svelte',
        'vue',
      })
      -- Solo agregar > si no hay ya uno adelante
      :with_pair(cond.not_after_regex '>')
      -- No agregar par cuando sea un tag de cierre </
      :with_pair(cond.not_before_regex('/', 1))
      -- No agregar par en comentarios
      :with_pair(cond.not_inside_quote()))

    -- Regla para auto-cerrar tags HTML (opcional pero muy útil)
    npairs.add_rule(Rule('>', '>', {
        'html',
        'xml',
        'javascriptreact',
        'typescriptreact',
        'astro',
        'svelte',
        'vue',
      })
      :with_pair(cond.none())
      :with_move(function(opts_move)
        return opts_move.char == '>'
      end)
      :use_key '>')
  end,
}
