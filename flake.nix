# flake.nix

{
  description = "My NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland/?submodules=1&rev=918d8340afd652b011b937d29d5eea0be08467f5"; # v0.41.2
    hyprlock.url = "github:hyprwm/hyprlock";
    hypridle.url = "github:hyprwm/hypridle";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprcursor-phinger.url = "github:Jappie3/hyprcursor-phinger";

    nixvim-config.url = "github:mtpham99/nixvim-config";
    wezterm.url = "github:wez/wezterm?dir=nix&rev=30ecc426ca8e4c4ff1ad81641ad8a4bf1e555649";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, sops-nix, disko, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages."${system}";
    pkgs-unstable = nixpkgs-unstable.legacyPackages."${system}";
  in
  {
    # host configurations
    nixosConfigurations = {

      grunfeld = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable;
          inherit inputs;
        };

        modules = [
          sops-nix.nixosModules.sops
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          ./hosts/grunfeld/configuration.nix
        ];
      };

      ruylopez = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable;
          inherit inputs;
        };

        modules = [
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./hosts/ruylopez/configuration.nix
        ];
      };
    };

    # home manager configurations
    homeConfigurations = {

      mpham = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit pkgs-unstable;
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
