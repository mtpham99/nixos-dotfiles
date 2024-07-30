# default.nix (hyprland)

{ lib, pkgs, config, inputs, ... }:
let
  colors = import ../theme/colors.nix { inherit lib; };
in
{
  imports = [
    ../scripts/volume.nix
    ../scripts/brightness.nix
    ../scripts/lock.nix
    ../scripts/screenshot.nix

    ../scripts/rofi.nix
    ../waybar
  ];

  config.home.packages = with pkgs; [
    cliphist # clipboard manager
    wl-clip-persist # persistent clipboard

    networkmanagerapplet # networkmanager applet
    blueman # bluetooth applet
  ];

  config.wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;

    settings = {
      # monitors
      # see https://wiki.hyprland.org/Configuring/Monitors
      monitor = ", preferred, auto, 2.0";

      # environment variables
      env = [
        # gpu selection/priority
        "WLR_DRM_DEVICES, /dev/dri/card0" # :/dev/dri/card1

        # enable tearing
        "WLR_DRM_NO_ATOMIC, 1"
      ];

      # execs
      exec-once = [
        # clipboard
        "wl-paste --type text --watch cliphist store" # cliphist (clipboard manager)
        "wl-paste --type image --watch cliphist store"
        "wl-clip-persist -c regular" # wl-clip-persist (preserve clips even after clip source closes)

        # applets
        "nm-applet"
        "blueman-applet"

        # bar
        "waybar"
      ];

      # general settings
      general = {
        gaps_in = 3;
        gaps_out = 3;
        border_size = 3;

        "col.active_border" = "rgba(${colors.border})";
        "col.inactive_border" = "rgba(${colors.border-inactive})";
      };

      # cursor settings
      cursor = {
        no_hardware_cursors = true;
        enable_hyprcursor = true;
      };

      # logs
      debug = {
        disable_logs = false;
      };

      # input settings
      input = {
        # keyboard
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        repeat_delay = 225;
        repeat_rate = 35;

        # mouse/touchpad
        sensitivity = 0.20;
        accel_profile = "flat";
        # force_no_accel = true;
        follow_mouse = 0;
        scroll_method = "2fg";
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
          tap-and-drag = true;
        };
      };

      # devices settings
      device = [
        # wireless mouse
        {
          name = "logitech-g305-1";
          sensitivity = -0.2;
          accel_profile = "flat";
          # force_no_accel = true;
        }
      ];

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          xray = false;
          new_optimizations = true;
          special = false;
        };

        drop_shadow = false;
        # shadow_range = 15;
        # shadow_offset = "0, 0";
        # shadow_render_power = 3;
        # "col.shadow" = ;
        # "col.shadow_inactive = ;

        active_opacity = 1.0;
        inactive_opacity = 1.0;
        fullscreen_opacity = 1.0;
      };

      # animation settings
      animations = {
        enabled = true;

        # curves
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 4, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 10, default"
          "fade, 1, 2, default"
          "workspaces, 1, 2, default"
          "specialWorkspace, 1, 2, default, slidevert"
        ];
      };

      # layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = false;
        smart_resizing = false;
      };

      # gesture settings
      gestures = {
        workspace_swipe = true;
      };

      # misc settings
      misc = {
        force_default_wallpaper = 0;
        disable_splash_rendering = false;
        initial_workspace_tracking = 1;

        focus_on_activate = true;
        animate_manual_resizes = false;
        animate_mouse_windowdragging = false;

        vfr = true;
      };

      # key binds
      bind = [
        # exit
        "SUPER, BACKSPACE, killactive"
        "SUPER, Q, killactive"
        "SUPER_ALT_CTRL, DELETE, exec, hyprctl dispatch exit"

        # lock
        "SUPER, ESCAPE, exec, sh \${HOME}/.local/bin/lock.sh"

        # terminal
        "SUPER, T, exec, wezterm start --always-new-process" # https://github.com/wez/wezterm/issues/5103#issuecomment-2078555510

        # file manager
        "SUPER, F, exec, thunar"

        # rofi
        "SUPER, V, exec, sh \${HOME}/.local/bin/rofi.sh --clipboard"
        "SUPER, R, exec, sh \${HOME}/.local/bin/rofi.sh --drun"
        "SUPER, C, exec, sh \${HOME}/.local/bin/rofi.sh --calc"
        "SUPER, E, exec, sh \${HOME}/.local/bin/rofi.sh --emoji"

        # screenshot
        "SUPER, PRINT, exec, sh \${HOME}/.local/bin/screenshot.sh"

        # layout
        "SUPER, SPACE, togglefloating"
        "SUPER, N, pseudo"
        "SUPER, M, togglesplit"

        # focus
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"

        # move to workspace
        "SUPER_SHIFT, 1, movetoworkspace, 1"
        "SUPER_SHIFT, 2, movetoworkspace, 2"
        "SUPER_SHIFT, 3, movetoworkspace, 3"
        "SUPER_SHIFT, 4, movetoworkspace, 4"
        "SUPER_SHIFT, 5, movetoworkspace, 5"
        "SUPER_SHIFT, 6, movetoworkspace, 6"
        "SUPER_SHIFT, 7, movetoworkspace, 7"
        "SUPER_SHIFT, 8, movetoworkspace, 8"
        "SUPER_SHIFT, 9, movetoworkspace, 9"
        "SUPER_SHIFT, 0, movetoworkspace, 10"

        # goto workspace
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # scroll workspace
        "SUPER, TAB, workspace, e+1"
        "SUPER_SHIFT, TAB, workspace, e-1"
        "SUPER, PAGE_UP, workspace, e-1"
        "SUPER, PAGE_DOWN, workspace, e+1"

        # special/scratch workspace
        "SUPER, S, togglespecialworkspace, scratch" # special workspace named "scratch"
        "SUPER_SHIFT, S, movetoworkspace, special:scratch"

        # special/files workspace
        # "SUPER, F, togglespecialworkspace, files" # special workspace named "files"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow" # left click
        "SUPER, mouse:273, resizewindow" # right click
      ];

      binde = [
        # resize active window
        "SUPER_SHIFT, H, resizeactive, -10 0"
        "SUPER_SHIFT, J, resizeactive, 0 10"
        "SUPER_SHIFT, K, resizeactive, 0 -10"
        "SUPER_SHIFT, L, resizeactive, 10 0"
      ];

      bindle = [
        # audio
        ", XF86AudioRaiseVolume, exec, sh \${HOME}/.local/bin/volume.sh --inc"
        ", XF86AudioLowerVolume, exec, sh \${HOME}/.local/bin/volume.sh --dec"
        ", XF86AudioMute, exec, sh \${HOME}/.local/bin/volume.sh --toggle"
        ", XF86AudioMicMute, exec, sh \${HOME}/.local/bin/volume.sh --toggle-mic"

        # brightness
        ", XF86MonBrightnessUp, exec, sh \${HOME}/.local/bin/brightness.sh --inc"
        ", XF86MonBrightnessDown, exec, sh \${HOME}/.local/bin/brightness.sh --dec"
      ];

      bindl = [
        # lid switch
        ", switch:Lid Switch, exec, sh \${HOME}/.local/bin/lock.sh"
        ", switch:on:Lid Switch, exec, hyprctl keyword monitor \", disable\""
        ", switch:off:Lid Switch, exec, hyprctl keyword monitor \", preferred, auto, 2\""
      ];

      # window rules
      windowrulev2 = [
        # dialogs
        "float, title:^(Open File)(.*)$"
        "float, title:^(Select a File)(.*)$"
        "float, title:^(Choose wallpaper)(.*)$"
        "float, title:^(Open Folder)(.*)$"
        "float, title:^(Save As)(.*)$"
        "float, title:^(Library)(.*)$"

        # thunar
        "float, class:^(thunar)$"
        "size 80% 80%, class:^(thunar)$"
        "center, class:^(thunar)$"

        # enable tearing for specific windows
        "immediate, class:^(mpv)$"

        # xwaland screen sharing
        # see https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing
        "opacity 0.0 override 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
      ];

      # workspace rules
      workspace = [
        # special workspace (scratch)
        "special:scratch, on-created-empty:[float; size 50% 98%; move 49.5% 1%] wezterm start --always-new-process"

        # special workspace (files)
        # "special:files, on-created-empty:[float; size 80% 80%; move 10% 5%] thunar"
      ];
    };
  };
}
