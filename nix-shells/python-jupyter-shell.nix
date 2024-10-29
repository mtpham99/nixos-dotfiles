# python-jupyter-shell.nix
# shell for using jupyterlab

{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      ipython
      jupyterlab
      ipywidgets
    ]))
  ];
}
