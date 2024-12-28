# default.nix (rofi)

{ pkgs, config, inputs, ... }:

{
  home.packages = [
    pkgs.papirus-icon-theme
    pkgs.nerd-fonts.iosevka
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    configPath = "${config.xdg.configHome}/rofi/config.rasi";

    # theme = ./theme.rasi;
    font = "Iosevka NFM SemiBold Obl 14";
    location = "center";
    xoffset = 0;
    yoffset = 0;

    extraConfig = {
      modi = "drun,calc,emoji";

      icon-theme = "Papirus";
      show-icons = true;

      display-drun = "󰣆 Apps";
      drun-display-format = "{icon} {name}";
      display-calc = "󰡱 Calculator";
      display-emoji = ":D Emoji";
    };
  };

  # rofi plugins
  # ensure plugins build against rofi-wayland
  programs.rofi.plugins = with pkgs; [
    rofi-calc
    rofi-emoji-wayland
  ];
  nixpkgs.overlays = [
    (final: prev: {
      rofi-calc = prev.rofi-calc.override {
        rofi-unwrapped = prev.rofi-wayland-unwrapped;
      };
      # rofi-emoji = prev.rofi-emoji.override {
      #   rofi-unwrapped = prev.rofi-wayland-unwrapped;
      # };
    })
  ];
}
