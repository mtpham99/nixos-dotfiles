# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, config, inputs, ... }:

{
  imports = [
    # sops secrets config
    ./sops.nix

    # include the results of the hardware scan.
    ./hardware-configuration.nix

    # thinkfan acpi module
    {
      boot.extraModprobeConfig = ''
        # enable fan control for thinkpads
        options thinkpad_acpi fan_control=1
      '';
    }

    # polyfills
    ../../modules/nixos/polyfills/nixpkgs-issue-55674.nix

    # enable nvidia
    ../../modules/nixos/nvidia.nix
    {
      nvidia.enable = true;
      nvidia.cuda.enable = true;
      nvidia.intelBusId = "PCI:0:2:0";
      nvidia.nvidiaBusId = "PCI:1:0:0";

      # some nvidia related env vars
      environment.variables = {
        # nvidia vaapi driver
        # NVD_LOG = 1;
        NVD_GPU = "/dev/dri/by-path/pci-0000:01:00.0-card";
        NVD_BACKEND = "direct";
      };
    }

    # video acceleration libs
    ../../modules/nixos/graphics.nix
    {
      # set default vaapi and vdpau backends
      environment.variables = {
        LIBVA_DRIVER_NAME = "iHD"; # manually set to "nvidia" when needed
        VDPAU_DRIVER = "nvidia";
      };
    }

    # podman
    ../../modules/nixos/docker.nix
    {
      docker.enable = true;
      docker.use-podman = true;
      docker.use-nvidia = true;
    }

    # duckdns systemd unit for domain ip update
    ../../modules/nixos/duckdns.nix
    {
      duckdns.enable = true;
      duckdns.domain = "grunfeld";
      duckdns.token-file = config.sops.secrets.duckdns-token.path;
    }

    # shadowsocks-rust (client template service)
    ../../modules/nixos/shadowsocks-rust.nix
    {
      shadowsocks-rust.enable = true;
      shadowsocks-rust.client-configs = [
        "gluetun-protonvpn-chicago75"
        "gluetun-protonvpn-swiss125"
        "gluetun-protonvpn-uk215"
        "gluetun-protonvpn-usiceland1"
      ];
    }

    # enable hyprland
    ../../modules/nixos/hyprland.nix
    { hyprland.enable = true; }

    # enable thunar
    ../../modules/nixos/thunar.nix
    { thunar.enable = true; }

    # jellyfin
    ../../modules/homelab/containers/docker-network.nix
    ../../modules/homelab/containers/media/jellyfin
    ../../modules/homelab/containers/observability/node_exporter
    {
      # bind mount data/media drive to jellyfin volume
      system.activationScripts."jellyfin-setup".text = ''
        mkdir -p /srv/jellyfin/media
      '';
      fileSystems."/srv/jellyfin/media" = {
        depends = [ "/mnt/data" ];
        device = "/mnt/data/media";
        fsType = "xfs";
        options = [ "bind" ];
      };

      homelab.containers = let
        docker-network-name = "hlab-ipvlan";
      in {
        docker-network = {
          enable = true;

          network-driver = "ipvlan";
          network-name = docker-network-name;
          interface = "wlp82s0";
          gateway = "10.10.0.1"; # "10.10.0.1";
          subnet = "10.10.0.0/16"; # "10.10.0.0/16"; # 10.10.0.1 - 10.10.255.254
          ip-range = "10.10.0.0/17"; # "10.10.0.0/17"; # 10.10.0.1 - 10.10.127.254

          enable-bridge = true;
          bridge-name = "${docker-network-name}-br";
          bridge-ip = "10.10.0.2";
        };

        jellyfin = {
          enable = true;
          container-name = "jellyfin";

          network = docker-network-name;
          ip = "10.10.10.1";
          add-to-bridge = true;
        };
        node_exporter = {
          enable = true;
          container-name = "node_exporter";
        };
      };
    }
  ];

  # package management
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ]; # enable flakes
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      trusted-users = [ "root" "@wheel" ];
    };

    # automatic cleanup
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  # auto update
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    dates = "03:30";
    randomizedDelaySec = "30min";
  };

  # kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  chaotic.scx.enable = true;
  chaotic.scx.scheduler = "scx_rusty";

  # kernel module packages
  # boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  # kernel parameters (boot time)
  boot.kernelParams = [ 
    # "quiet"
    # "splash"
    "zswap.enabled=1"
    "zswap.compressor=zstd"
  ];

  # kernel parameters (modprobe)
  boot.extraModprobeConfig = ''
  '';

  # systemd-boot
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "auto"; # 0 1 2 auto max keep
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # initrd luks devices
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices = {
    cr_root = {
      device = "/dev/disk/by-label/CR_ROOT";
      preLVM = true;
    };

    cr_data0 = {
      device = "/dev/disk/by-label/CR_DATA0";
      preLVM = true;
    };
  };

  # tmp on tmpfs
  boot.tmp = {
    cleanOnBoot = true;
    useTmpfs = true;
    tmpfsSize = "100%";
  };

  # firmware
  # hardware.enableAllFirmware = true; # requires `nixpkgs.config.allowUnfree = true`
  services.fwupd.enable = true;

  # power
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.undervolt = {
    enable = true;
    coreOffset = -125;
    gpuOffset = -115;
  };
  services.tlp = {
    enable = true;

    settings = {
      # cpu governor
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # cpu energy policy
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      # cpu freq (%)
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # cpu turbo boost
      CPU_BOOST_ON_AC = 1;
      CPU_BOOT_ON_BAT = 0;

      # cpu dynamic boost
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      # igpu freq
      INTEL_GPU_MIN_FREQ_ON_AC = 500;
      INTEL_GPU_MAX_FREQ_ON_AC = 1135; # max of i7 9750H
      INTEL_GPU_MIN_FREQ_ON_BAT = 350; # min of i7 9750H
      INTEL_GPU_MAX_FREQ_ON_BAT = 500;

      # igpu boost
      INTEL_GPU_BOOST_FREQ_ON_AC = 1135;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 500;

      # battery charging limits
      START_CHARGE_THRESH_BAT0 = 45;
      STOP_CHARGE_THRESH_BAT0 = 55;
    };
  };

  # locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "C.UTF-8";
  };
  console = {
    keyMap = "us";
  };
  time.timeZone = "America/Chicago";

  # environment variables (globals set early by pam)
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    XDG_BIN_HOME = "\${HOME}/.local/bin";

    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  # environment variables (globals set in /etc/profile)
  environment.variables = {
  };

  # interactive shell inits
  environment.interactiveShellInit = ''
    # aliases
    grep="grep --color=auto"
    diff="diff --color=auto"
    ip="ip --color=auto"
  '';

  # networking
  networking.hostName = "grunfeld";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # ssh
  ];
  networking.firewall.allowedUDPPorts = [
    5353 # avahi/mdns
  ];

  # ssh
  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # wireguard
  networking.wg-quick.interfaces = let
    fn-generate-wg-quick-protonvpn-interface = { 
      interface-name,
      secret-key-path,
      public-key,
      endpoint,
      autostart,
    }: {
      # proton vpn addresses
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];

      # path to secret key file
      privateKeyFile = secret-key-path;

      # killswitch
      # postUp = ''
      #   ${pkgs.iptables}/bin/iptables -I OUTPUT \
      #     ! -o ${interface-name} \
      #     -m mark ! --mark $(${pkgs.wireguard-tools}/bin/wg show ${interface-name} fwmark) \
      #     -m addrtype ! --dst-type LOCAL \
      #     -j REJECT

      #   ${pkgs.iptables}/bin/ip6tables -I OUTPUT \
      #     ! -o ${interface-name} \
      #     -m mark ! --mark $(${pkgs.wireguard-tools}/bin/wg show ${interface-name} fwmark) \
      #     -m addrtype ! --dst-type LOCAL \
      #     -j REJECT
      # '';

      # preDown = ''
      #   ${pkgs.iptables}/bin/iptables -D OUTPUT \
      #     ! -o ${interface-name} \
      #     -m mark ! --mark $(${pkgs.wireguard-tools}/bin/wg show ${interface-name} fwmark) \
      #     -m addrtype ! --dst-type LOCAL \
      #     -j REJECT

      #   ${pkgs.iptables}/bin/ip6tables -D OUTPUT ! \
      #     -o ${interface-name} \
      #     -m mark ! --mark $(${pkgs.wireguard-tools}/bin/wg show ${interface-name} fwmark) \
      #     -m addrtype ! --dst-type LOCAL \
      #     -j REJECT
      # '';

      peers = [
        {
          publicKey = public-key;
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = endpoint;
          persistentKeepalive = 25;
        }
      ];

      autostart = autostart;
    };
  in 
  {
    # proton vpn (chicago 75)
    # moderate-nat_nat-pmp_vpn-accel_mal-ads-track_Chicago75
    proton_chicago = fn-generate-wg-quick-protonvpn-interface {
      interface-name = "proton_chicago";
      secret-key-path = config.sops.secrets.wg-protonvpn-chicago75-sk.path;
      public-key = "qT0lxDVbWEIyrL2A40FfCXRlUALvnryRz2aQdD6gUDs=";
      endpoint = "89.187.180.40:51820";
      autostart = false;
    };

    # proton vpn (switzerland 125)
    # moderate-nat_nat-pmp_vpn-accel_mal-ads-track_CH125
    proton_swiss = fn-generate-wg-quick-protonvpn-interface {
      interface-name = "proton_swiss";
      secret-key-path = config.sops.secrets.wg-protonvpn-ch125-sk.path;
      public-key = "MDJPYLKrGYv11Mis97Ihk/aPULhC5us44hx3Fa1/8lk=";
      endpoint = "149.88.27.233:51820";
      autostart = false;
    };

    # proton vpn (uk 215)
    # moderate-nat_nat-pmp_vpn-accel_mal-ads-track_UK215
    proton_uk = fn-generate-wg-quick-protonvpn-interface {
      interface-name = "proton_uk";
      secret-key-path = config.sops.secrets.wg-protonvpn-uk215-sk.path;
      public-key = "kYWXMo4RQ08rekIUo0keVmqRkfhPrB8Y288ZQ7ZMYjU=";
      endpoint = "149.40.63.129:51820";
      autostart = false;
    };

    # proton vpn (secure core us-iceland 1)
    # nat-pmp_vpn-accel_mal-ads-track_secure-core_US-ICELAND1
    proton_secure = fn-generate-wg-quick-protonvpn-interface {
      interface-name = "proton_secure";
      secret-key-path = config.sops.secrets.wg-protonvpn-us_iceland1-sk.path;
      public-key = "d2QJ4qxbpm7HSiEbssGku1X+UNnZBcEWcApgS0xgI34=";
      endpoint = "185.159.158.213:51820";
      autostart = false;
    };

    ruylopez = {
      address = [ "10.10.130.2" ];
      dns = [ "10.10.1.2" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.ruylopez-wireguard-grunfeld-peer-sk.path;

      peers = [
        {
          publicKey = "9LJkcG39HbGVJ+UI5xe8pv8v+wfaqB07UCG8i1KWxVg=";
          presharedKey = "qYyjtJCbK+/BPf4BK80TT/qVUHeBgW/9g0l7fEaKNeI=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "ruylopez.duckdns.org:13737";
          persistentKeepalive = 25;
        }
      ];

      autostart = false;
    };
  };

  # samba client/mount
  fileSystems."/mnt/samba/ruylopez/admin" = {
    device = "//ruylopez.local/admin";
    fsType = "smb3";
    depends = [ "/" ];
    options = (
      let
        mount-options = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=root,gid=wheel,file_mode=0660,dir_mode=0770";
      in
      [ "${mount-options},vers=3.1.1,credentials=${config.sops.secrets.samba-ruylopez-admin-creds.path}" ]
    );
  };
  fileSystems."/mnt/samba/ruylopez/public" = {
    device = "//ruylopez.local/public";
    fsType = "cifs";
    depends = [ "/" ];
    options = (
      let
        mount-options = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=nobody,gid=nogroup,file_mode=0666,dir_mode=0777";
      in
      [ "${mount-options},vers=2.0,guest" ]
    );
  };

  # avahi/mdns
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  }; 

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket"; # enable A2DP sink
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  services.snapper = {
    configs = {
      mpham = {
        SUBVOLUME = "/home/mpham";
        ALLOW_USERS = [ "mpham" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };
  };

  # system packages
  environment.systemPackages = with pkgs; [
    # backlight
    brightnessctl

    # filesystems
    libxfs
    cifs-utils

    # resource monitor
    btop
    nvtopPackages.full
    duf

    # networking
    wireguard-tools
    libnatpmp
    nmap
    mtr
    dig
    tcpdump
    lsof

    # file utils
    zip
    unzip
    wget
    p7zip

    # security
    sops
    age

    # graphics
    libva-utils
    vdpauinfo

    # dev
    gh

    # misc
    fastfetch
  ];

  # locate
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    localuser = null;
    interval = "hourly";
    pruneNames = [ ".snapshots" ]; # ignore snapshot directories
  };

  # gnupg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # git
  programs.git = {
    enable = true;

    prompt.enable = true; # sources git-prompt.sh which provides some shell prompt utility functions (e.g. __git_ps1)
  };

  # tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  # neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
  };

  # shells
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bash zsh ];

  # dconf
  programs.dconf = {
    enable = true;

    profiles = {
      "user".databases = [
        {
          settings = {};
        }
      ];
    };
  };

  # user 
  users.users.mpham = {
    description = "Matthew Pham";
    isNormalUser = true;
    uid = 1000;
    group = "mpham";
    createHome = true;
    home = "/home/mpham";
    shell = pkgs.bash;

    extraGroups = [
      "wheel" # enable "sudo"
      "mlocate" # allow non-root user to use mlocate
    ];

    hashedPasswordFile = config.sops.secrets.mpham-hashed-user-pass.path;

    openssh.authorizedKeys.keyFiles = [
      ../../ssh-keys/grunfeld.pub
      ../../ssh-keys/ruylopez.pub
      ../../ssh-keys/najdorf.pub
      ../../ssh-keys/ipad.pub
      ../../ssh-keys/iphone.pub
    ];
  };
  users.groups.mpham = {
    gid = 1000;
    members = [ "mpham" ];
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
