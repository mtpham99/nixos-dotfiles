# python-dev-shell.nix
# python development shell used with virtual environments
# source/inspiration: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/python.section.md#how-to-consume-python-modules-using-pip-in-a-virtual-environment-like-i-am-used-to-on-other-operating-systems-how-to-consume-python-modules-using-pip-in-a-virtual-environment-like-i-am-used-to-on-other-operating-systems

{ pkgs ? import <nixpkgs> { } }:
let
  lib-path = with pkgs; lib.makeLibraryPath [
    stdenv.cc.cc
    zlib
  ];
in
pkgs.mkShell {

  # virtual environment folder sourced on shell start ( or created if missing )
  venvDir = "./.venv";

  # run time deps
  buildInputs = with pkgs; [
    python3Packages.python

    # creates and sources virtual env on shell start
    python3Packages.venvShellHook
  ];

  # command ran after creating venv
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install --upgrade pip
    pip install -r ./requirements.txt
  '';

  # command ran after sourcing virtual env
  postShellHook = ''
    export LD_LIBRARY_PATH=''${LD_LIBRARY_PATH}:${lib-path}
  '';
}
