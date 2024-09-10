# python-shell.nix
# generic shell used for virtual envs and jupyter
# general workflow is creating virtual env then adding venv to jupyter's kernels

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    # python packages
    (pkgs.python3.withPackages(ps: with ps; [
      # general
      ipython

      # jupyter
      jupyterlab
      ipywidgets

      # standard tools
      numpy
      pandas
      requests
    ]))
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib
  '';
}
