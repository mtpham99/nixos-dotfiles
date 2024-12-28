# flake.nix

{
  description = "My NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle.url = "github:hyprwm/hypridle";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprcursor-phinger.url = "github:Jappie3/hyprcursor-phinger";

    wezterm.url = "github:wez/wezterm?dir=nix";
    nixvim-config.url = "github:mtpham99/nixvim-config";
  };

  outputs = { self, nixpkgs, chaotic, nixos-hardware, sops-nix, disko, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";
  in
  {
    # host configurations
    nixosConfigurations = {

      grunfeld = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
        };

        modules = [
          chaotic.nixosModules.default
          sops-nix.nixosModules.default
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          ./hosts/grunfeld/configuration.nix
        ];
      };

      ruylopez = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs;
        };

        modules = [
          chaotic.nixosModules.default
          sops-nix.nixosModules.default
          disko.nixosModules.default
          ./hosts/ruylopez/configuration.nix
        ];
      };
    };

    # home manager configurations
    homeConfigurations = {

      mpham = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs;
        };

        modules = [
          sops-nix.homeManagerModules.sops
          ./modules/home-manager/mpham/home.nix
        ];
      };
    };
  };
}
