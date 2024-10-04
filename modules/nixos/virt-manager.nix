# virt-manager.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.virt-manager;
in
{
  options = {
    virt-manager = {
      enable = lib.mkEnableOption "enable virt-manager";
      users = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of users to add to \"libvirtd\" group";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    users.users = lib.listToAttrs (
      lib.map (user: {
        name = user;
        value = { extraGroups = [ "libvirtd" ]; };
      }) cfg.users
    );
  };
}
