# default.nix (shells)

{ lib, pkgs, config, ... }:

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
      IPYTHONDIR = "\${XDG_CONFIG_HOME}/ipython";
      JUPYTER_CONFIG_DIR = "\${XDG_CONFIG_HOME}/jupyter";
      PYTHONSTARTUP = "\${XDG_CONFIG_HOME}/pythonrc";  # see below
    };

    shellAliases = {
      # shorthand commands
      "grep" = "grep --color=auto";
      "diff" = "diff --color=auto";
      "ip" = "ip --color=auto";
      "du" = "du -hs";

      # home-manager update
      "home-manager-update" = "home-manager switch --flake \${HOME}/.dotfiles#$(whoami) --show-trace";

      # nixos update (local)
      "nixos-update" = "sudo -k nixos-rebuild switch --flake \${HOME}/.dotfiles#$(hostname) --show-trace";

      # nixos update (home-lab remote)
      "nixos-update-ruylopez" = "sudo -k NIX_SSHOPTS=\"-i ${config.home.homeDirectory}/.ssh/mpham_grunfeld -F ${config.home.homeDirectory}/.ssh/config\" nixos-rebuild switch --target-host ruylopez --flake ~/.dotfiles#ruylopez --show-trace";

      # home dir cleanup
      "nvidia-settings" = "nvidia-settings --config=\"\${XDG_CONFIG_HOME}\"/nvidia/settings";
      "wget" = "wget --hsts-file=\"\${XDG_DATA_HOME}/wget-hsts\"";
    };

    # activation scripts/commands
    activation = {
      touchPythonHistoryFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run touch ''${XDG_STATE_HOME}/python_history
      '';
    };
  };

  # pythonrc file for moving history ( see above )
  xdg.configFile."pythonrc".text = ''
    def is_vanilla() -> bool:
        import sys
        return not hasattr(__builtins__, '__IPYTHON__') and 'bpython' not in sys.argv[0]


    def setup_history():
        import os
        import atexit
        import readline
        from pathlib import Path

        if state_home := os.environ.get('XDG_STATE_HOME'):
            state_home = Path(state_home)
        else:
            state_home = Path.home() / '.local' / 'state'

        history: Path = state_home / 'python_history'

        readline.read_history_file(str(history))
        atexit.register(readline.write_history_file, str(history))


    if is_vanilla():
        setup_history()
  '';
}
