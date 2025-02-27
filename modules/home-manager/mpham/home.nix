# home.nix

{ lib, pkgs, config, ... }:

{
  imports = [
    # sops secrets config
    ./sops.nix

    # general environment
    ./xdg
    ./shells
    ./scripts

    # terminal confs
    ./wezterm
    ./neovim

    # window mangaer/desktop setup
    ./hyprland
    ./rofi
    ./dunst
    ./waybar


    # general theming (fonts/gtk/icons)
    ./theme
    { cursors.enable-hyprcursor = true; }

    # user confs
    ./ssh
    ./git

    # applications
    ./mpv
    ./browsers

    # misc
    ./latex
  ];

  programs.home-manager.enable = true;
  home = {
    username = "mpham";
    homeDirectory = "/home/mpham";

    packages = with pkgs; [
      # documents
      libreoffice
      kdePackages.okular

      # image/video
      yt-dlp
      imv
      inkscape
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
        ];
      })

      # misc
      fastfetch
    ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
