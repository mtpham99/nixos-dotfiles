# default.nix (browsers)

{ ... }:

{
  imports = [
    ./psd.nix
    ./librewolf.nix
    ./brave.nix
    ./firefox.nix
  ];
}
