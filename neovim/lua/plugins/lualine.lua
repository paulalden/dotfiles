return {
  "nvim-lualine/lualine.nvim",
  -- event = "VimEnter",
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

    local contains = function(list, x)
      for _, v in pairs(list) do
        if v == x then
          return true
        end
      end

      return false
    end

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
      local data
      local symbols = {}

      if contains(require("config.excluded_filetypes"), vim.bo.filetype) then
        return
      end

      -- Relative path
      data = vim.fn.expand("%:t")
      data = modules.utils.stl_escape(data)

      if data == "" then
        data = self.options.symbols.unnamed
      end

      local state
      if vim.bo.modified then
        state = self.options.symbols.modified
      elseif vim.bo.modifiable == false or vim.bo.readonly == true then
        state = self.options.symbols.readonly
      else
        state = self.options.symbols.saved
      end
      table.insert(symbols, state)

      -- data = data .. "" .. (#symbols > 0 and "" .. table.concat(symbols, "") or "")
      local icon = icons[vim.fn.expand("%:e")]
      if icon then
        icon = icon.icon
      else
        icon = ""
      end

      data = icon .. " " .. data .. "" .. (#symbols > 0 and "" .. table.concat(symbols, "") or "")

      local hi_color
      if vim.bo.modified then
        hi_color = self.highlights.modified
      elseif vim.bo.readonly then
        hi_color = self.highlights.readonly
      else
        hi_color = self.highlights.saved
      end

      data = highlight.component_format_highlight(hi_color) .. data

      return data
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "Ranger" },
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
        "nvim-tree",
        "man",
        "lazy",
        "trouble",
        "toggleterm",
      },
    })
  end,
}
