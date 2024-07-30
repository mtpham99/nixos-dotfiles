# default.nix (scripts)

{ ... }:

{
  imports = [
    ./volume.nix
    ./brightness.nix
    ./lock.nix
    ./rofi.nix
    ./screenshot.nix
  ];
}
