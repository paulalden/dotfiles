return {
  "iguanacucumber/magazine.nvim",
  name = "nvim-cmp", -- Otherwise highlighting gets messed up
  lazy = true,
  event = "InsertEnter",
  dependencies = {
    { "iguanacucumber/mag-nvim-lsp", name = "cmp-nvim-lsp", opts = {} },
    { "iguanacucumber/mag-nvim-lua", name = "cmp-nvim-lua" },
    { "iguanacucumber/mag-buffer", name = "cmp-buffer" },
    { "iguanacucumber/mag-cmdline", name = "cmp-cmdline" },
    "https://codeberg.org/FelipeLema/cmp-async-path",
    "hrsh7th/cmp-nvim-lsp-document-symbol", -- For textDocument/documentSymbol
    "lukas-reineke/cmp-under-comparator", -- Tweak completion order
    "f3fora/cmp-spell",
  },
  config = function()
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then
      return
    end

    local check_backspace = function()
      local col = vim.fn.col(".") - 1

      return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
    end

    local kind_icons = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Codeium = "",
      Field = "",
      Variable = "",
      Class = "ﴯ",
      Interface = "",
      Module = "",
      Property = "ﰠ",
      Unit = "",
      Value = "",
      Enum = "",
      Keyword = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    }
    local compare = require("cmp.config.compare")
    local types = require("cmp.types")

    cmp.setup({
      mapping = {
        ["<C-n>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif check_backspace() then
            fallback()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-p>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      },
      formatting = {
        expandable_indicator = true,
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)

          vim_item.menu = ({
            codeium = "[LLM]",
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            spell = "[Spelling]",
          })[entry.source.name]

          return vim_item
        end,
      },
      sources = {
        { name = "lazydev" },
        { name = "codeium" },
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 3 },
        { name = "async_path" },
        {
          name = "spell",
          option = {
            keep_all_entries = false,
            enable_in_context = function()
              return require("cmp.config.context").in_treesitter_capture("spell")
            end,
          },
        },
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.locality,
          compare.kind,
          compare.length,
          compare.order,
        },
      },
      window = {
        completion = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "Normal:TelescopePreviewBorder,TelescopePreviewBorder:Pmenu,CursorLine:PmenuSel,Search:None",
          winblend = 0,
          scrolloff = 0,
          col_offset = 0,
          side_padding = 1,
          scrollbar = true,
        },
        documentation = cmp.config.window.bordered({
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
          winblend = 0,
        }),
      },
      experimental = {
        ghost_text = false,
        native_menu = false,
      },
      enabled = function()
        local disabled = false

        disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
        disabled = disabled or (vim.fn.reg_recording() ~= "")
        disabled = disabled or (vim.fn.reg_executing() ~= "")

        return not disabled
      end,
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
        filtering_context_budget = 3,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 200,
      },
      preselect = types.cmp.PreselectMode.Item,
      completion = {
        autocomplete = {
          types.cmp.TriggerEvent.TextChanged,
        },
        completeopt = "menu,menuone,noselect",
        keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
        keyword_length = 1,
      },
      matching = {
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = true,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
        disallow_symbol_nonprefix_matching = true,
      },
    })
  end,
}
