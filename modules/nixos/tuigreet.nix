# tuigreet.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.tuigreet;
in
{
  options = {
    tuigreet = {
      enable = lib.mkEnableOption "enable tuigreet";

      user = lib.mkOption {
        type = lib.types.str;
        description = "greetd user";
        default = "greeter";
      };

      command = lib.mkOption {
        type = lib.types.str;
        description = "tuigreet command";
        example = "\${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ greetd.tuigreet ];

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = "${cfg.command}";
          user = "${cfg.user}";
        };
      };
    };
  };
}
