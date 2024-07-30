# default.nix (git)

{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Matthew T. Pham (Github.com)";
    userEmail = "mtpham.github@quantamail.net";

    signing = {
      key = null;
      signByDefault = true;
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # github cli
  programs.gh = {
    enable = true;

    settings = {
      editor = ""; # "" will use environment specification
      git_protocol = "ssh";
    };
  };
}
