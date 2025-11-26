return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy', -- Load the plugin very late
  config = function()
    require('notify').setup {
      -- Add your desired configuration options here
      -- For example:
      timeout = 5000,
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        DEBUG = '',
        TRACE = '✎',
      },
    }
    vim.notify = require 'notify' -- Overrides default vim.notify with nvim-notify
  end,
}
