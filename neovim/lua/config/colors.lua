-- Nord palette. The base colours are NOT duplicated here: they are parsed from
-- the single source of truth — tmux/config/nord.conf — at load time, so they
-- can never drift out of sync. Only Neovim-specific derived shades (that don't
-- exist in the shared palette) are defined locally below.
local M = {}

local colors = {}

-- Parse `name="#rrggbb"` lines from the shared palette. Guarded so a missing
-- file degrades gracefully (colours fall back to the local shades) instead of
-- erroring during startup.
local palette = (os.getenv("HOME") or "") .. "/.config/tmux/config/nord.conf"
local f = io.open(palette, "r")
if f then
  for line in f:lines() do
    local name, hex = line:match('^([%w_]+)="(#%x+)"')
    if name then
      colors[name] = hex
    end
  end
  f:close()
end

-- Neovim-specific shades, not part of the shared palette.
colors.bg_light = "#353b49"
colors.bg_unfocused = "#282e38"
colors.bg_dark = "#191c22"
colors.fg_dark = "#6C7A96"
colors.orange_washed = "#dfac9c"
colors.magenta_dark = "#9d6b93"
colors.magenta_light = "#cbb1c7"

M.colors = colors

return M
