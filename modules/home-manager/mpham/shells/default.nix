# default.nix (shells)

{ pkgs, config, ... }:

{
  imports = [
    # ./zsh # not currently using/maintaining
    ./bash
  ];

  # general shell environment
  home = {
    sessionPath = [];

    sessionVariables = {
      # editor/pager
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";

      # home dir cleanup
      CUDA_CACHE_PATH = "\${XDG_CACHE_HOME}/nv";
      DOCKER_CONFIG = "\${XDG_CONFIG_HOME}/docker";
    };

    shellAliases = {
      # shorthand commands
      "grep" = "grep --color=auto";
      "diff" = "diff --color=auto";
      "ip" = "ip --color=auto";
      "du" = "du -hs";

      # home-manager update
      "home-manager-update" = "home-manager switch --flake \${HOME}/.dotfiles#$(whoami)";

      # nixos update (local)
      "nixos-update" = "sudo -k nixos-rebuild switch --flake \${HOME}/.dotfiles#$(hostname) --show-trace";

      # nixos update (home-lab remote)
      "nixos-update-ruylopez" = "sudo -k NIX_SSHOPTS=\"-i ${config.home.homeDirectory}/.ssh/mpham_grunfeld -F ${config.home.homeDirectory}/.ssh/config\" nixos-rebuild switch --target-host ruylopez --flake ~/.dotfiles#ruylopez --show-trace";

      # home dir cleanup
      "nvidia-settings" = "nvidia-settings --config=\"\${XDG_CONFIG_HOME}\"/nvidia/settings";
      "wget" = "wget --hsts-file=\"\${XDG_DATA_HOME}/wget-hsts\"";
    };
  };
}
