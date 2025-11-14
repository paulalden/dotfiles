return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
    { "Exafunction/codeium.nvim", priority = 49 },
  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "enter",
      ["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
      -- ["<esc>"] = { "cancel", "fallback" },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          align_to = "label",
          columns = {
            { "kind_icon" },
            { "label" },
            { "kind", gap = 1 },
          },
          padding = { 1, 1 }, -- padding left, right
          components = {
            label = {
              width = { fill = true, max = 60 },
              text = function(ctx)
                return ctx.label .. ctx.label_detail
              end,
            },
            kind_icon = {
              text = function(ctx)
                return ctx.kind_icon .. ctx.icon_gap .. " "
              end,
            },
            kind = {
              ellipsis = false,
              width = { fill = true },
              text = function(ctx)
                return "[" .. ctx.kind .. "]"
              end,
              highlight = function(ctx)
                return ctx.kind_hl
              end,
            },
            label_description = {
              width = { max = 30 },
              text = function(ctx)
                return "[" .. ctx.label_description .. "]"
              end,
              highlight = "BlinkCmpLabelDescription",
            },
          },
        },
      },
      documentation = {
        window = { border = "rounded" },
        auto_show = false,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = vim.g.ai_cmp,
      },
    },
    signature = { window = { border = "single" } },
    sources = {
      default = {
        "lazydev",
        "lsp",
        "path",
        "codeium",
        "buffer",
        "snippets",
      },
      providers = {
        codeium = {
          name = "Codeium",
          module = "codeium.blink",
          async = true,
        },
        buffer = {
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(function(bufnr)
                return vim.bo[bufnr].buftype == ""
              end, vim.api.nvim_list_bufs())
            end,
          },
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100, -- show at a higher priority than lsp
        },
      },
    },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  },
  opts_extend = { "sources.default" },
}