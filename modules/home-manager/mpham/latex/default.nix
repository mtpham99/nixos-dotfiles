# default.nix (latex)

{ pkgs, ... }:
let
  tex-package = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium
      # fonts
      fontaxes
      fira
      cormorantgaramond
      noto
      roboto
      libertine

      # sections
      enumitem
      titlesec

      # page formats
      preprint;
  });
in 
{
  home.packages = with pkgs; [ tex-package ];
}
