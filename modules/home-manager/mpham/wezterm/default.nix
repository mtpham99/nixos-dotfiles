# default.nix (wezterm)

{ pkgs, inputs, ... }:
let
  wezterm-config = pkgs.fetchFromGitHub {
    owner = "mtpham99";
    repo = "wezterm-config";
    rev = "main";
    sha256 = "5XuCiFrY8I/n5nskmhT+Bkz1ccsdz02xW1pI5dXR184=";
  };
in
{
  xdg.configFile."wezterm".source = wezterm-config;

  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages."${pkgs.system}".default;

    extraConfig = ''
    '';
  };
}
