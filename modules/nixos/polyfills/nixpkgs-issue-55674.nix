# nixpkgs-issue-55674.nix
# credit to AndrewKvalheim
# see https://github.com/NixOS/nixpkgs/issues/55674
# see https://codeberg.org/AndrewKvalheim/configuration/src/branch/main/packages/nixpkgs-issue-55674.nix
# polyfill for replacing nixpkgs.config.allowUnfreePredicate with config.allowedUnfree list of unfree packages

{ config, lib, ... }:

{
  options = {
    allowedUnfree = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.allowedUnfree;
  };
}
