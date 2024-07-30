# default.nix (zsh)

{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    dotDir = ".config/zsh"; # relative to user home

    history = {
      extended = true;
      size = 999999;
      path = "\${XDG_STATE_HOME}/zsh/history";
    };

    sessionVariables = {
      # move .z to data dir
      _Z_DATA = "\${XDG_DATA_HOME}/zsh/z";
    };

    shellAliases = {
    };

    initExtra = ''
      # create data dir if missing
      mkdir -p ''${XDG_DATA_HOME}/zsh

      # move zcompdump to cache dir
      compinit -d ''${XDG_CACHE_HOME}/zsh/zcompdump-"$ZSH_VERSION"
    '';

    logoutExtra = ''
    '';

    plugins = [
      # powerlevel10k
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
      {
        name = "powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }

      # zsh-z
      {
        name = "z";
        src = "${pkgs.zsh-z}/share/zsh-z/";
        file = "zsh-z.plugin.zsh";
      }
    ];
  }; 
}
