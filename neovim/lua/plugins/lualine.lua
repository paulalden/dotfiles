return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local highlight = require("lualine.highlight")
    local colors = require("config.colors").colors
    local fname = require("lualine.components.filename"):extend()
    local modules = require("lualine_require").lazy_require({ utils = "lualine.utils.utils" })
    local icons = require("nvim-web-devicons").get_icons()

    local config = {
      saved = { bg = colors.grey12, fg = colors.grey9 },
      modified = { bg = colors.orange_washed, fg = colors.grey10 },
      readonly = { bg = colors.red, fg = colors.fg },
    }

    local default_options = {
      symbols = {
        saved = " [✓]",
        modified = " [~]",
        readonly = " [✘]",
        unnamed = "[No Name]",
        newfile = "[New]",
      },
    }

    function fname:init(options)
      fname.super.init(self, options)

      self.highlights = {
        saved = highlight.create_component_highlight_group(config.saved, "filename_status_saved", self.options),
        modified = highlight.create_component_highlight_group(
          config.modified,
          "filename_status_modified",
          self.options
        ),
        readonly = highlight.create_component_highlight_group(
          config.readonly,
          "filename_status_readonly",
          self.options
        ),
      }

      self.options = vim.tbl_deep_extend("force", self.options or {}, default_options)

      if self.options.color == nil then
        self.options.color = ""
      end
    end

    function fname:update_status()
      local data = vim.fn.expand("%:t")
      data = modules.utils.stl_escape(data)

      if data == "" then
        data = self.options.symbols.unnamed
      end

      -- Determine state symbol and highlight
      local state, hi_color
      if vim.bo.modified then
        state = self.options.symbols.modified
        hi_color = self.highlights.modified
      elseif vim.bo.modifiable == false or vim.bo.readonly then
        state = self.options.symbols.readonly
        hi_color = self.highlights.readonly
      else
        state = self.options.symbols.saved
        hi_color = self.highlights.saved
      end

      -- File icon
      local icon_data = icons[vim.fn.expand("%:e")]
      local icon = icon_data and icon_data.icon or ""

      data = highlight.component_format_highlight(hi_color) .. icon .. " " .. data .. state

      return data
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = require("config.excluded_filetypes"),
        globalstatus = true,
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "macro",
            fmt = function()
              local reg = vim.fn.reg_recording()

              if reg ~= "" then
                return "recording @" .. reg
              end
            end,
            color = { fg = colors.yellow },
            draw_empty = false,
          },
        },
        lualine_x = { fname },
        lualine_y = { "diff" },
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {
        "man",
        "lazy",
        "trouble",
      },
    })
  end,
}
