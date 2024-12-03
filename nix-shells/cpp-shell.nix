# cpp-shell.nix
# generic shell for c/c++ and related tools

{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = with pkgs; [
    # compilers
    gcc
    clang

    # debugger
    gdb

    # profilers/optimizations/benchmarks
    valgrind
    perf-tools
    gperftools
    gbenchmark

    # build systems
    cmake
    ninja

    # tools/static analyzers/formatters/etc
    clang-tools
    cppcheck

    # testing
    catch2_3 # catch_2
    gtest

    # common libs
    boost
    fmt
    spdlog
  ];
}
