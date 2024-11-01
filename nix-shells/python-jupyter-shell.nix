# python-jupyter-shell.nix
# shell for using jupyterlab

{ pkgs ? import <nixpkgs> { } }:
let
  lib-path = with pkgs; lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
  ];
in
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      ipython
      jupyterlab
      ipywidgets
    ]))
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=''${LD_LIBRARY_PATH}:${lib-path}
  '';
}
