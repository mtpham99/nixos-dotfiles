# graphics.nix

{ lib, pkgs, config, ... }:

{
  imports = [
    ./nvidia.nix
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.vpl-gpu-rt # intel quick sync video
      pkgs.intel-media-driver # LIBVA_DRIVER_NAME=iHD (newer)
      pkgs.intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older, helps with browser compatibility)
      pkgs.libvdpau-va-gl # VDPAU_DRIVER=va_gl (vdpau backend for vaapi -- h.264 only?)
    ] ++ lib.optional config.nvidia.enable pkgs.nvidia-vaapi-driver; # LIBVA_DRIVER_NAME=nvidia
      # NOTE: nvidia is also vdpau compatible via VDPAU_DRIVER=nvidia
  };

  # utils for testing/info
  environment.systemPackages = with pkgs; [
    libva-utils # vainfo
    vdpauinfo # vdpauinfo
    glxinfo # eglinfo glxinfo glxgears
  ];
}
