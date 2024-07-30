# wayland.nix

{ pkgs, ... }:

{
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
    QT_QPA_PLATFORM = "wayland"; # explicit qt use wayland
  };

  environment.systemPackages = with pkgs; [
    # wl protcol and compositor info
    wayland-utils # wayland-info

    # xrandr clone for wayland
    wlr-randr # wlr-randr

    # provides wl-copy/paste and allowed apps to share clipboard
    # e.g. allows vim copy to system clipboard
    wl-clipboard 
  ];
}
