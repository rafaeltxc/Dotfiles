local M = {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  opts = {
    options = {
      icons_enabled = true,
      theme = 'nord',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      }
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {
        {
          'branch',
          icon = ''
        }
      },
      lualine_c = {
        'filetype',
        {
          'filename',
          file_status = true,
          path = 1,
          shorting_target = 30,
          symbols = {
              modified = '',
              readonly = '',
              unnamed = '[No Name]',
              newfile = '',
          },
        },
      },
    },
  },

  config = function(_, opts)
    local ll = require("lualine")
    ll.setup(opts)
  end
}

return M
