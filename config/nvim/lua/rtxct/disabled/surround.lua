local M = {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {

        --[[ Old text                    Command         New text
--------------------------------------------------------------------------------
    surr*ound_words             ysiw)           (surround_words)
    *make strings               ys$"            "make strings"
    [delete ar*ound me!]        ds]             delete around me!
    'change quot*es'            cs'"            "change quotes"
    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    remove <b>HTML t*ags</b>    dst             remove HTML tags
    delete(functi*on calls)     dsf             function calls ]]

      keymaps = {
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
      },
    },

    config = function(_, opts)
      local sur = require("nvim-surround")
      sur.setup(opts)
    end
}

return M
