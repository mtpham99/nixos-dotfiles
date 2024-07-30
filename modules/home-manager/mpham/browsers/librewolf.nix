# librewolf.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [ librewolf ];

  # add desktop entry to run with gpu
  xdg.desktopEntries.Librewolf-GPU = {
    type = "Application";
    name = "Librewolf GPU";
    genericName = "Web Browser";
    icon = "librewolf";
    prefersNonDefaultGPU = true;
    exec = "env __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only LIBVA_DRIVER_NAME=nvidia VDPAU_DRIVER=nvidia NVD_BACKEND=direct MOZ_DRM_DEVICE=/dev/dri/card1 NVD_GPU=/dev/dri/card1 MOZ_DISABLE_RDD_SANDBOX=1 librewolf --new-window %U";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "application/vnd.mozilla.xul+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
  };
}
