return {
  "rmehri01/onenord.nvim",
  lazy = false,
  config = function()
    local colors = require("config.colors").colors

    require("onenord").setup({
      borders = true,
      fade_nc = false,
      styles = {
        comments = "italic",
        strings = "NONE",
        keywords = "NONE",
        functions = "NONE",
        variables = "NONE",
        diagnostics = "italic",
      },
      disable = {
        cursorline = false,
        eob_lines = true,
      },
      custom_highlights = {
        -- Examples
        -- LspDiagnosticsUnderlineInformation = { style = config.styles.diagnostics, sp = colors.info },
        -- ["@text.uri"] = { fg = colors.cyan, style = "underline" },
        -- Todo = { fg = colors.yellow, bg = colors.none, style = "bold,italic" },
        -- DiagnosticError = { link = "LspDiagnosticsDefaultError" },

        NormalFloat = { fg = colors.magenta, bg = colors.bg_light },

        CursorLine = { bg = colors.grey14 },
        CursorColumn = { bg = colors.grey14 },

        -- Blink
        BlinkCmpMenuBorder = { fg = colors.magenta },
        BlinkCmpMenu = { bg = colors.bg_light },

        -- Fidget
        FidgetTask = { link = "Comment" },

        -- Snack Dashboard
        SnacksDashboardTitle = { fg = colors.cyan },
        SnacksDashboardHeader = { link = "Comment" },
        SnacksDashboardFooter = { link = "Comment" },
        SnacksDashboardDesc = { link = "Comment" },
        SnacksDashboardIcon = { link = "Comment" },
        SnacksDashboardFile = { link = "Comment" },
        SnacksDashboardSpecial = { link = "Comment" },
        SnacksDashboardKey = { link = "Comment" },

        -- Snack Picker
        SnacksPickerDir = { link = "Comment" },
        SnacksPickerBoxTitle = { bg = colors.bg, fg = colors.fg_dark },
        SnacksPickerBoxBorder = { bg = colors.bg, fg = colors.magenta },
        SnacksPickerList = { bg = colors.bg },
        SnacksPickerListTitle = { bg = colors.bg, fg = colors.fg_dark },
        SnacksPickerListBorder = { bg = colors.bg, fg = colors.magenta },
        SnacksPickerInput = { bg = colors.bg },
        SnacksPickerInputTitle = { bg = colors.bg, fg = colors.fg_dark },
        SnacksPickerInputBorder = { bg = colors.bg, fg = colors.magenta },
        SnacksPickerPreview = { bg = colors.bg },
        SnacksPickerPreviewTitle = { bg = colors.bg, fg = colors.fg_dark },
        SnacksPickerPreviewBorder = { bg = colors.bg, fg = colors.magenta },

        -- Snack indent line scope
        SnacksIndent = { fg = "#353c4a" },
        SnacksIndentScope = { fg = colors.grey11 },

        -- FZF Lua
        SnacksPickerDir = { link = "Comment" },
        FzfLuaBorder = { bg = colors.bg, fg = colors.fg_dark },
        FzfLuaFzfBorder = { bg = colors.bg, fg = colors.fg_dark },
        FzfLuaFzfBorderFull = { bg = colors.bg, fg = colors.fg_dark },
        -- SnacksPickerList = { bg = colors.bg },
        -- SnacksPickerListTitle = { bg = colors.bg, fg = colors.fg_dark },
        -- SnacksPickerListBorder = { bg = colors.bg, fg = colors.bg },
        -- SnacksPickerInput = { bg = colors.bg },
        -- SnacksPickerInputTitle = { bg = colors.bg, fg = colors.fg_dark },
        -- SnacksPickerInputBorder = { bg = colors.bg, fg = colors.bg },
        -- SnacksPickerPreview = { bg = colors.bg },
        -- SnacksPickerPreviewTitle = { bg = colors.bg, fg = colors.fg_dark },
        -- SnacksPickerPreviewBorder = { bg = colors.bg, fg = colors.bg },

        -- QuickFix
        QuickFixLineNr = { fg = colors.grey10 },
        QuickFixHeaderHard = { fg = colors.grey10 },
        QuickFixHeaderSoft = { fg = colors.grey10 },
        Delimiter = { fg = colors.grey10 },

        -- Nvim Core
        Folded = { fg = colors.grey10 },

        -- LSP Document Highlights
        LspReferenceText = { bg = colors.grey11, style = "none" },
        LspReferenceRead = { link = "LspReferenceText", style = "none" },
        LspReferenceWrite = { link = "LspReferenceText", style = "none" },

        -- Better Quick List
        BqfPreviewFloat = { bg = colors.bg },
        BqfPreviewBorder = { bg = colors.bg, fg = colors.magenta },
        BqfPreviewTitle = { bg = colors.bg, fg = colors.magenta },

        -- Whichkey
        WhichKeyFloat = { bg = colors.grey14 },
        WhichKey = { fg = colors.yellow },
        WhichKeyGroup = { fg = colors.grey7 },
        WhichKeySeparator = { link = "Comment" },
        WhichKeyDesc = { fg = colors.grey7 },
        WhichKeyValue = { fg = colors.grey7 },
        WhichKeyBorder = { fg = colors.magenta, bg = colors.bg },

        -- Color columns
        VirtColumn = { bg = colors.bg, fg = colors.grey14 },
        VirtColumnNonText = { fg = colors.grey13 },

        --
        IblIndent = { fg = colors.grey13 },

        -- Git Signs
        GitSignsAdd = { fg = colors.green },
        GitSignsChange = { fg = colors.yellow },
        GitSignsDelete = { fg = colors.red },

        -- Git Conflict
        GitConflictCurrent = { bg = colors.green, fg = colors.fg },
        GitConflictCurrentLabel = { bg = colors.green, fg = colors.fg },
        GitConflictIncoming = { bg = colors.red, fg = colors.bg },
        GitConflictIncomingLabel = { bg = colors.red, fg = colors.bg },

        -- Lualine
        StatusLine = { bg = colors.bg },
        StatusLineNC = { bg = colors.bg },
        StatusLineTerm = { bg = colors.bg },

        -- Noice
        NoicePopup = { bg = colors.bg_dark },
        NoicePopupMenu = { bg = colors.bg_dark },
        NoiceCmdlinePopupBorder = { fg = colors.magenta },
      },
    })
  end,
}