# default.nix (neovim)
# see https://github.com/mtpham99/nixvim-config

{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.nixvim-config.packages."${pkgs.system}".default
  ];

  # add vi/vim aliases
  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
