-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Hopscotch.256'
config.font = wezterm.font('Lilex Nerd Font')
config.font_size = 10.0
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20

-- and finally, return the configuration to wezterm
return config
