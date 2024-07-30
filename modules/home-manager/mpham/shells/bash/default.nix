# default.nix (bash)

{ lib, config, ... }:

{
  programs.bash = {
    enable = true;

    enableCompletion = true;

    sessionVariables = {
    };

    # bash specific aliases
    shellAliases = {
    };

    # .bashrc
    # included in non-interactive and interactive shells
    bashrcExtra = ''
    '';

    # .bashrc
    # included only in interactive shells
    initExtra = ''
      # create the history file directory if it doesn't exist
      # if it doesn't exist, bash won't write the file
      mkdir -p ${config.xdg.stateHome}/bash

      # disable XON/XOFF feature, which overrides <C-s>, to enable <C-s> forward search during bash-reverse-search
      stty -ixon

      # custom bash prompt (thanks to https://bash-prompt-generator.org)
      PROMPT_COMMAND='PS1_CMD1=$(__git_ps1 " (%s)")'; PS1='[\[\e[38;5;200;1m\]\u\[\e[0m\]@\[\e[38;5;51;1m\]\h\[\e[0m\]:\w\[\e[38;5;46m\]''${PS1_CMD1}\[\e[0m\]]\$ '
    '';

    # .profile
    profileExtra = ''
    '';

    # .bash_logout
    logoutExtra = ''
    '';

    historyFile = "${config.xdg.stateHome}/bash/history";
    historyFileSize = -1;
    historySize = -1;
  };
}
