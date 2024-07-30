# nvidia.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.nvidia;
in
{
  options = {
    nvidia = {
      enable = lib.mkEnableOption "enable nvidia";

      nvidiaBusId = lib.mkOption {
        type = lib.types.str;
        description = ''
          nvidia gpu bus id
        '';
        default = "";
      };

      intelBusId = lib.mkOption {
        type = lib.types.str;
        description = ''
          intel gpu bus id
        '';
        default = "";
      };

      amdgpuBusId = lib.mkOption {
        type = lib.types.str;
        description = ''
          amd gpu bus id
        '';
        default = "";
      };

      cuda.enable = lib.mkEnableOption "enable cuda";
    };
  };

  config = lib.mkIf cfg.enable {

    # enable unfree nvidia/cuda packages
    # see ./polyfills/nixpkgs-issue-55674.nix
    allowedUnfree = lib.mkMerge [
      # Nvidia
      [
        "nvidia-settings"
        "nvidia-persistenced"
        "nvidia-x11"
      ]

      # cuda (cudaPackages set)
      (lib.mkIf cfg.cuda.enable [
        "auto-add-cuda-compat-runpath-hook"
        "cuda-merged"
        "cuda-samples"
        "cuda_cccl"
        "cuda_compat"
        "cuda_cudart"
        "cuda_cuobjdump"
        "cuda_cupti"
        "cuda_cuxxfilt"
        "cuda_demo_suite"
        "cuda_dcumentation"
        "cuda_gdb"
        "cuda_nsight"
        "cuda_nvcc"
        "cuda_nvdisasm"
        "cuda_nvml_dev"
        "cuda_nvprof"
        "cuda_nvprune"
        "cuda_nvrtc"
        "cuda_nvtx"
        "cuda_nvvp"
        "cuda_opencl"
        "cuda_profiler_api"
        "cuda_sanitizer_api"
        "cudatoolkit"
        "cudnn"
        # "cudnn_8_9"
        "fabricmanager"
        "libcublas"
        "libcudla"
        "libcufft"
        "libcufile"
        "libcurand"
        "libcusolver"
        "libcusparse"
        "libcutensor"
        # "libcutensor_1_6"
        "libnpp"
        "libnvidia_nscq"
        "libnvjitlink"
        "libnvjpeg"
        "mark-for-cudatoolkit-root-hook"
        "nccl"
        "nccl-tests"
        "nsight_compute"
        "nsight_systems"
        "nsight_vse"
        "nvidia_driver"
        "nvidia_fs"
        "saxpy-unstablesetup-cuda-hook-stdenv-linux"
        "tensorrt"
        # "tensorrt_8_6"
        "visual_studio_integration"
      ])
    ];

    # load nvidia driver for xorg and wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    # enable opengl
    # > 24.05
    hardware.graphics = {
      enable = true;

      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
    # <= 24.05
    # hardware.opengl = {
    #   enable = true;
    #   driSupport = true;

    #   extraPackages = with pkgs; [
    #     nvidia-vaapi-driver
    #   ];
    # };

    # nvidia config
    hardware.nvidia = {
      # modesetting is required
      modesetting.enable = true;

      # nvidia power management (experimental)
      # this option saves the entire vram to /tmp instead of only essentials
      powerManagement.enable = true;

      # Fine-grained power management (experimental)
      # turns off gpu when not in use (requires turing or newer gpus)
      powerManagement.finegrained = true;

      # dynamic boost
      # balance power between cpu and gpu for support laptops using nvidia-powerd daemon
      dynamicBoost.enable = false;

      # Use nvidia open source kernel module (not to be confused with nouveau)
      open = false;

      # enable nvidia settings menu "nvidia-settings"
      nvidiaSettings = true;

      # select specific package (optional)
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.production;
      # package = config.boot.kernelPackages.nvidiaPackages.beta;
      # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
      # package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

      # nvidia prime (hybrid graphics)
      prime = {
        intelBusId = "${cfg.intelBusId}";
        nvidiaBusId = "${cfg.nvidiaBusId}";
        amdgpuBusId = "${cfg.amdgpuBusId}";

        # use either offload or sync mode
        # sync.enable = true;
        offload = {
          enable = lib.mkIf (cfg.nvidiaBusId != "" && (cfg.intelBusId != "" || cfg.amdgpuBusId != "")) true;
          enableOffloadCmd = lib.mkIf (cfg.nvidiaBusId != "" && (cfg.intelBusId != "" || cfg.amdgpuBusId != "")) true;
        };
      };
    };

    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

    environment.systemPackages = with pkgs; [
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
    ];
  };
}
