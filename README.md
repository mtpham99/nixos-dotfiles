# My NixOS Dotfiles

Configuration files for my NixOS devices.

## Configurations

- [Ruylopez (Homelab Machine)](https://github.com/mtpham99/nixos-dotfiles/tree/main/hosts/ruylopez/configuration.nix)

- [Grunfeld (Primary/Laptop)](https://github.com/mtpham99/nixos-dotfiles/tree/main/hosts/grunfeld/configuration.nix)

## Modules

- [Dotfiles](https://github.com/mtpham99/nixos-dotfiles/tree/main/modules/home-manager/mpham)

    - See ["home.nix"](https://github.com/mtpham99/nixos-dotfiles/tree/main/modules/home-manager/mpham/home.nix)

    - Window Manager: [Hyprland](https://github.com/hyprwm/Hyprland)

    - Terminal: [Wezterm](https://github.com/wez/wezterm)

- [Homelab](https://github.com/mtpham99/nixos-dotfiles/tree/main/modules/homelab)

    - See ["ruylopez" configuration](https://github.com/mtpham99/nixos-dotfiles/tree/main/hosts/ruylopez/configuration.nix)

    - [Unbound dns container w/ redis cachedb and metrics exporter](https://github.com/mtpham99/unbound-redis-metrics)

        - Implemented [here](https://github.com/mtpham99/nixos-dotfiles/tree/main/modules/homelab/containers/networking/unbound)

## Info/Links

### NixOS

- [Disko: Declarative disk partitioning and formatting](https://github.com/nix-community/disko)

- [Sops: Secrets management](https://github.com/Mic92/sops-nix)

- [NixOS-Anywhere: NixOS deployment/install via SSH](https://github.com/nix-community/nixos-anywhere)

- [Home-manager: User environment configuration](https://nixos.wiki/wiki/Home_Manager)


### My Neovim (via nixvim) Config

- [My Neovim Config](https://github.com/mtpham99/nixvim-config)
