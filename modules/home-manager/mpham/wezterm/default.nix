# default.nix (wezterm)

{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Iosevka" ]; }) # terminal font
  ];

  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages."${pkgs.system}".default;

    extraConfig = ''
      local wezterm = require('wezterm')

      return {
        -- font
        font = wezterm.font('Iosevka NFM SemiBold'),
        font_size = 14,

        -- cursor
        animation_fps = 1,
        default_cursor_style = 'BlinkingBar',
        cursor_blink_ease_in = 'Constant',
        cursor_blink_ease_out = 'Constant',

        -- window
        adjust_window_size_when_changing_font_size = false,
        window_padding = {
          left = 0,
          right = 0,
          top = 0,
          bottom = 0,
        },
        window_background_opacity = 0.60,

        -- tabs
        use_fancy_tab_bar = false,
        hide_tab_bar_if_only_one_tab = false,
        tab_bar_at_bottom = false,

        -- colors
        color_scheme = 'iTerm2 Default',
        -- colors = {
        --   tab_bar = {
        --     -- background = ,
        --     -- new_tab = { bg_color = , fg_color = , intensity = 'Bold', },
        --     -- new_tab_hover = { bg_color = , fg_color = , intensity = 'Bold', },
        --     -- format-tab-title = ,
        --     -- active_tab = ,
        --     -- inactive_tab = ,
        --     -- inactive_tab_hover = ,
        --   },
        -- },

        -- icons
        detect_password_input = false,

        -- behaviors
        selection_word_boundary = ' \t\n{}[]()\"`\',;:|=&!%',
        exit_behavior = 'CloseOnCleanExit',
        window_close_confirmation = 'AlwaysPrompt',
        scrollback_lines = 999999,

        -- system
        check_for_updates = false,
        enable_wayland = true, -- prefer wayland
        front_end = 'OpenGL',
        webgpu_power_preference = 'LowPower',

        -- multiplexing
        -- leader key
        leader = { key = 'a', mods = 'CTRL' },

        -- tmux-like keybinds
        keys = {
          -- split panes
          {
            key = '%',
            mods = 'LEADER|SHIFT',
            action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
          },
          {
            key = '"',
            mods = 'LEADER|SHIFT',
            action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
          },

          -- select panes
          {
            key = 'h',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection('Left'),
          },
          {
            key = 'j',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection('Down'),
          },
          {
            key = 'k',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection('Up'),
          },
          {
            key = 'l',
            mods = 'LEADER',
            action = wezterm.action.ActivatePaneDirection('Right'),
          },

          -- close panes
          {
            key = 'x',
            mods = 'LEADER',
            action = wezterm.action.CloseCurrentPane({ confirm = true }),
          },

          -- resize panes
          {
            key = 'H',
            mods = 'LEADER',
            action = wezterm.action.AdjustPaneSize({ 'Left', 5 }),
          },
          {
            key = 'J',
            mods = 'LEADER',
            action = wezterm.action.AdjustPaneSize({ 'Down', 5 }),
          },
          {
            key = 'K',
            mods = 'LEADER',
            action = wezterm.action.AdjustPaneSize({ 'Up', 5 }),
          },
          {
            key = 'L',
            mods = 'LEADER',
            action = wezterm.action.AdjustPaneSize({ 'Right', 5 }),
          },

          -- toggle zoom/maximize
          {
            key = 'z',
            mods = 'LEADER',
            action = wezterm.action.TogglePaneZoomState,
          },

          -- create/close tabs
          {
            key = 'c',
            mods = 'LEADER',
            action = wezterm.action.SpawnTab('CurrentPaneDomain'),
          },
          {
            key = '&',
            mods = 'LEADER|SHIFT',
            action = wezterm.action.CloseCurrentTab({ confirm = true }),
          },

          -- select tabs
          {
            key = '1',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(0),
          },
          {
            key = '2',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(1),
          },
          {
            key = '3',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(2),
          },
          {
            key = '4',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(3),
          },
          {
            key = '5',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(4),
          },
          {
            key = '6',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(5),
          },
          {
            key = '7',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(6),
          },
          {
            key = '8',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(7),
          },
          {
            key = '9',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(8),
          },
          {
            key = '0',
            mods = 'LEADER',
            action = wezterm.action.ActivateTab(9),
          },
          {
            key = 'p',
            mods = 'LEADER',
            action = wezterm.action.ActivateTabRelative(-1),
          },
          {
            key = 'n',
            mods = 'LEADER',
            action = wezterm.action.ActivateTabRelative(1),
          },

          -- copy mode (activate & paste from)
          {
            key = '[',
            mods = 'LEADER',
            action = wezterm.action.ActivateCopyMode,
          },
          {
            key = ']',
            mods = 'LEADER',
            action = wezterm.action.PasteFrom('PrimarySelection'),
          },
        },

        -- copy/search mode keybinds
        key_tables = {
          copy_mode = {
            -- quit/exit
            {
              key = 'q',
              mods = 'NONE',
              action = wezterm.action.CopyMode('Close'),
            },
            {
              key = 'Escape',
              mods = 'NONE',
              action = wezterm.action.CopyMode('Close'),
            },

            -- navigation
            {
              key = 'h',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveLeft'),
            },
            {
              key = 'j',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveDown'),
            },
            {
              key = 'k',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveUp'),
            },
            {
              key = 'l',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveRight'),
            },
            {
              key = 'LeftArrow',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveLeft'),
            },
            {
              key = 'DownArrow',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveDown'),
            },
            {
              key = 'UpArrow',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveUp'),
            },
            {
              key = 'RightArrow',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveRight'),
            },
            {
              key = 'w',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveForwardWord'),
            },
            {
              key = 'b',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveBackwardWord'),
            },
            {
              key = 'W',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveForwardWord'),
            },
            {
              key = 'B',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveBackwardWord'),
            },

            {
              key = '0',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToStartOfLine'),
            },
            {
              key = '$',
              mods = 'SHIFT',
              action = wezterm.action.CopyMode('MoveToEndOfLineContent'),
            },
            {
              key = 'Enter',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToStartOfNextLine'),
            },

            {
              key = 'G',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToScrollbackBottom'),
            },

            {
              key = 'g',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToScrollbackTop'),
            },

            {
              key = 'PageUp',
              mods = 'NONE',
              action = wezterm.action.CopyMode('PageUp'),
            },
            {
              key = 'PageDown',
              mods = 'NONE',
              action = wezterm.action.CopyMode('PageDown'),
            },
            {
              key = 'u',
              mods = 'CTRL',
              action = wezterm.action.CopyMode('PageUp'),
            },
            {
              key = 'd',
              mods = 'CTRL',
              action = wezterm.action.CopyMode('PageDown'),
            },

            -- move cursor
            {
              key = 'H',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToViewportTop'),
            },
            {
              key = 'M',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToViewportMiddle'),
            },
            {
              key = 'L',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToViewportBottom'),
            },
            {
              key = 'o',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToSelectionOtherEnd'),
            },
            {
              key = 'O',
              mods = 'NONE',
              action = wezterm.action.CopyMode('MoveToSelectionOtherEndHoriz'),
            },

            -- selection
            {
              key = 'v',
              mods = 'NONE',
              action = wezterm.action.CopyMode({ SetSelectionMode = 'Cell' }),
            },
            {
              key = 'V',
              mods = 'NONE',
              action = wezterm.action.CopyMode({ SetSelectionMode = 'Line' }),
            },
            {
              key = 'v',
              mods = 'CTRL',
              action = wezterm.action.CopyMode({ SetSelectionMode = 'Block' }),
            },

            -- copy and exit
            {
              key = 'y',
              mods = 'NONE',
              action = wezterm.action.Multiple {
                wezterm.action.CopyTo('ClipboardAndPrimarySelection'),
                wezterm.action.CopyMode('Close'),
              },
            },

            -- enter search mode to edit the pattern
            -- when the search pattern is an empty string, the existing pattern is preserved
            {
              key = '/',
              mods = 'NONE',
              action = wezterm.action.Search({ CaseSensitiveString = ''' }),
            },
            {
              key = '?',
              mods = 'NONE',
              action = wezterm.action.Search({ CaseInSensitiveString = ''' }),
            },
            {
              key = 'n',
              mods = 'NONE',
              action = wezterm.action.CopyMode('NextMatch'),
            },
            {
              key = 'N',
              mods = 'NONE',
              action = wezterm.action.CopyMode('PriorMatch'),
            },
            {
              key = 'p',
              mods = 'NONE',
              action = wezterm.action.CopyMode('PriorMatch'),
            },
          },

        search_mode = {
          {
            key = 'Escape',
            mods = 'NONE',
            action = wezterm.action.CopyMode('Close'),
          },
          {
            key = 'Enter',
            mods = 'NONE',
            action = wezterm.action.ActivateCopyMode,
          },
          {
            key = 'c',
            mods = 'CTRL',
            action = wezterm.action.ActivateCopyMode,
          },
          {
            key = 'n',
            mods = 'CTRL',
            action = wezterm.action.CopyMode('NextMatch'),
          },
          {
            key = 'p',
            mods = 'CTRL',
            action = wezterm.action.CopyMode('PriorMatch'),
          },
          {
            key = 'r',
            mods = 'CTRL',
            action = wezterm.action.CopyMode('CycleMatchType'),
          },
          {
            key = 'u',
            mods = 'CTRL',
            action = wezterm.action.CopyMode('ClearPattern'),
          },
        },
      },
    }
  '';
  };
}
