# My NixOS Dotfiles

My NixOS configuration files.


## Configurations

- [Ruylopez (Homelab Machine)](/hosts/ruylopez)

- [Grunfeld (Primary/Laptop)](/hosts/grunfeld)


## Modules

- [Dotfiles](/modules/home-manager/mpham)

    - See [home-manager configs](/modules/home-manager/mpham)

    - Window Manager: [Hyprland](https://github.com/hyprwm/Hyprland)

    - Terminal: [Wezterm](https://github.com/wez/wezterm)

    - Text Editor: [Neovim](https://neovim.io/)

        - [My Neovim (via nixvim) Config](https://github.com/mtpham99/nixvim-config)

        - [Nixvim: configure Neovim using Nix](https://github.com/nix-community/nixvim)

- [Homelab](/modules/homelab)

    - See ["ruylopez" configuration](/hosts/ruylopez)

    - Mostly containers for running DNS, VPNs, Media Server, etc. ([here](/modules/homelab/containers)).

        - Also see [Unbound DNS + Redis Cache DB + Prometheus/Loki Metrics + Dashboard](https://github.com/mtpham99/unbound-redis-metrics)

- [Nixos](/modules/nixos)

    - General modules for systemwide configs (e.g. docker, virt-manager, nvidia, etc.)


## Nix-Shells

- [Python-Dev-Shell](/nix-shells/python-dev-shell)

    - Shell for running [JupyterLab](https://jupyter.org/)


## Info/Links

1. [Disko: Declarative disk partitioning and formatting](https://github.com/nix-community/disko)

2. [Sops: Secrets management](https://github.com/Mic92/sops-nix)

3. [NixOS-Anywhere: NixOS deployment/install via SSH](https://github.com/nix-community/nixos-anywhere)

4. [Home-manager: User environment configuration](https://nixos.wiki/wiki/Home_Manager)
