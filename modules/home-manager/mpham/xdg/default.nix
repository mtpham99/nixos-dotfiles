# default.nix (xdg)

{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      pkgs.xdg-utils # xdg-open, etc
    ];

    # home manager prefer xdg dirs
    home.preferXdgDirectories = true;

    # nixos use xdg dirs
    # allows moving .nix-profile, .nix-channels, and .nix-defexpr to .local/state/nix
    nix.package = pkgs.nix;
    nix.settings.use-xdg-base-directories = true;

    # user xdg dirs
    xdg.userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/desktop";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
      videos = "${config.home.homeDirectory}/videos";
    };

    # default applications
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = [ "okularApplication_pdf.desktop" "brave.desktop" ];

        "inode/directory" = [ "thunar.desktop" ];
        "inode/mountpoint" = [ "thunar.desktop" ];

        "image/png" = [ "imv.desktop" "inkscape.desktop" ];
        "image/jpeg" = [ "img.desktop" "inkscape.desktop" ];
        "image/svg" = [ "img.desktop" "inkscape.desktop" ];

        "text/html" = [ "brave.desktop" ];
        "x-scheme-handler/http" = [ "brave.desktop" ];
        "x-scheme-handler/https" = [ "brave.desktop" ];
        "x-scheme-handler/mailto" = [ "brave.desktop" ];
        "x-scheme-handler/about" = [ "brave.desktop" ];
        "x-scheme-handler/unknown" = [ "brave.desktop" ];
      };
    };
  };
}
