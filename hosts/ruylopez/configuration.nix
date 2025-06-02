# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, config, inputs, ... }:

{
  imports = [
    # include the results of the hardware scan
    ./hardware-configuration.nix

    # filesystem via disko
    ./disko.nix

    # specify sops secrets files
    ./sops.nix

    # podman
    ../../modules/nixos/docker.nix
    {
      docker.enable = true;
      docker.use-podman = true;
    }

    # duckdns systemd unit for domain ip update
    ../../modules/nixos/duckdns.nix
    {
      duckdns.enable = true;
      duckdns.domain = "ruylopez";
      duckdns.token-file = config.sops.secrets.duckdns-token.path;
    }

    # neovim
    {
      environment.systemPackages = [ inputs.nixvim-config.packages."${pkgs.system}".default ];
      environment.variables = {
        EDITOR = "${inputs.nixvim-config.packages."${pkgs.system}".default}/bin/nvim";
        SUDO_EDITOR = "${inputs.nixvim-config.packages."${pkgs.system}".default}/bin/nvim";
        VISUAL = "${inputs.nixvim-config.packages."${pkgs.system}".default}/bin/nvim";
        PAGER = "less";
      };
    }

    # homelab containers
    ../../modules/homelab/containers/docker-network.nix
    ../../modules/homelab/containers/networking/unbound
    ../../modules/homelab/containers/networking/gluetun
    ../../modules/homelab/containers/networking/wireguard
    ../../modules/homelab/containers/deluge
    ../../modules/homelab/containers/observability/prometheus
    ../../modules/homelab/containers/observability/grafana
    ../../modules/homelab/containers/observability/loki
    ../../modules/homelab/containers/observability/node_exporter
    ../../modules/homelab/containers/observability/github_traffic
    ../../modules/homelab/containers/media/komga
    ../../modules/homelab/containers/postgres/pt4
    {
      homelab.containers = let
        docker-network-name = "hlab-mvlan";

        unbound-ip = "10.10.1.1";

        # static ips configured via dhcp server
        ruylopez-ip = "10.10.129.1";
        grunfeld-ip = "10.10.129.2";
        najdorf-ip = "10.10.129.3";

        grafana-ip = "10.10.2.1";
        prometheus-ip = "10.10.2.2";
        loki-ip = "10.10.2.3";
        github-traffic-ip = "10.10.2.4";

        protonvpn-chicago-ip = "10.10.1.10";
        deluge-ip = protonvpn-chicago-ip;

        jellyfin-ip = "10.10.10.1";
        komga-ip = "10.10.10.2";

        postgres-pt4-ip = "10.10.3.1";
      in {
        docker-network = {
          enable = true;

          network-driver = "macvlan";
          network-name = docker-network-name;
          interface = "eno1";
          gateway = "10.10.0.1"; # "10.10.0.1";
          subnet = "10.10.0.0/16"; # "10.10.0.0/16"; # 10.10.0.1 - 10.10.255.254
          ip-range = "10.10.0.0/17"; # "10.10.0.0/17"; # 10.10.0.1 - 10.10.127.254

          enable-bridge = true;
          bridge-name = "${docker-network-name}-br";
          bridge-ip = "10.10.0.2";
        };
        unbound = {
          enable = true;
          container-name = "unbound-redis";

          network = docker-network-name;
          ip = "${unbound-ip}";
          add-to-bridge = true;

          loki-address = "loki.lan:3100";

          custom-config = ''
            # A Records
            local-data: "ruylopez.lan. A ${ruylopez-ip}"
            local-data: "grunfeld.lan. A ${grunfeld-ip}"
            local-data: "najdorf.lan. A ${najdorf-ip}"

            local-data: "unbound.lan. A ${unbound-ip}"

            local-data: "grafana.lan. A ${grafana-ip}"
            local-data: "prometheus.lan. A ${prometheus-ip}"
            local-data: "loki.lan. A ${loki-ip}"
            local-data: "github_traffic.lan. A ${github-traffic-ip}"

            local-data: "jellyfin.lan. A ${jellyfin-ip}"
            local-data: "deluge.lan. A ${deluge-ip}"

            local-data: "postgres_pt4.lan. A ${postgres-pt4-ip}"
          '';
        };
        gluetun = {
          enable = true;

          containers = {
            gluetun-protonvpn-chicago117 = {
              env-files = [
                "${config.homelab.containers.gluetun.config-pkg}/protonvpn-chicago117.env"
                config.sops.secrets.gluetun-protonvpn-chicago117-docker-env-secrets.path
              ];
              network = docker-network-name;
              ip = protonvpn-chicago-ip;
              add-to-bridge = true;
            };
            gluetun-protonvpn-swiss125 = {
              env-files = [
                "${config.homelab.containers.gluetun.config-pkg}/protonvpn-swiss125.env"
                config.sops.secrets.gluetun-protonvpn-swiss125-docker-env-secrets.path
              ];
              network = docker-network-name;
              ip = "10.10.1.11";
              add-to-bridge = true;
            };
            gluetun-protonvpn-uk215 = {
              env-files = [
                "${config.homelab.containers.gluetun.config-pkg}/protonvpn-uk215.env"
                config.sops.secrets.gluetun-protonvpn-uk215-docker-env-secrets.path
              ];
              network = docker-network-name;
              ip = "10.10.1.12";
              add-to-bridge = true;
            };
            gluetun-protonvpn-usiceland1 = {
              env-files = [
                "${config.homelab.containers.gluetun.config-pkg}/protonvpn-usiceland1.env"
                config.sops.secrets.gluetun-protonvpn-usiceland1-docker-env-secrets.path
              ];
              network = docker-network-name;
              ip = "10.10.1.13";
              add-to-bridge = true;
            };
          };
        };
        wireguard = {
          enable = true;
          container-name = "wireguard";

          network = docker-network-name;
          ip = "10.10.1.3";
          add-to-bridge = true;

          dns = unbound-ip;
        };
        deluge = {
          enable = true;
          container-name = "deluge";

          network-container = "gluetun-protonvpn-chicago117";
        };
        grafana = {
          enable = true;
          container-name = "grafana";

          network = docker-network-name;
          ip = grafana-ip;
          add-to-bridge = true;
        };
        prometheus = {
          enable = true;
          container-name = "prometheus";

          network = docker-network-name;
          ip = prometheus-ip;
          add-to-bridge = true;
        };
        loki = {
          enable = true;
          container-name = "loki";

          network = docker-network-name;
          ip = loki-ip;
          add-to-bridge = true;
        };
        node_exporter = {
          enable = true;
          container-name = "node_exporter";
        };
        github_traffic = {
          enable = true;
          container-name = "github_traffic";

          network = docker-network-name;
          ip = github-traffic-ip;
          add-to-bridge = true;
        };
        komga = {
          enable = true;
          container-name = "komga";

          network = docker-network-name;
          ip = komga-ip;
          add-to-bridge = true;
        };
        postgres = let
          inherit docker-network-name;
        in
        {
          pt4 = {
            enable = true;
            container-name = "postgres-pt4";
            network = docker-network-name;
            ip = postgres-pt4-ip;
            add-to-bridge = true;
          };
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
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
  };

  # kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = pkgs.linuxPackages_cachyos-server;

  # kernel sysctls
  boot.kernel.sysctl = {
    "vm.overcommit_memory" = 1;
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

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
  boot.initrd.systemd.enable = true;
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "auto"; # 0 1 2 auto max keep
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # firmware
  # hardware.enableAllFirmware = true; # requires `nixpkgs.config.allowUnfree = true`
  services.fwupd.enable = true;

  # networking
  networking.hostName = "ruylopez";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

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

  # samba server
  services.samba = {
    enable = true;
    package = pkgs.samba4Full;

    openFirewall = true;
    settings = {
      # global settings
      global = {
        security = "user";
        invalidUsers = [ "root" ];

        "server role" = "standalone server";
        workgroup = "WORKGROUP";
        "smb encrypt" = "desired";
        "map to guest" = "Bad User";
        "log level" = 3;
        "log file" = "/var/log/samba/%m";
      };

      # shares
      public = {
        path = "/srv/samba/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      admin = {
        "valid users" = "admin";
        path = "/srv/samba/admin";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
  # used to advertise to windows hosts
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  # samba setup script
  system.activationScripts.samba-setup.text = ''
    echo "Creating Samba Users..."

    # create samba share dirs
    mkdir -p /srv/samba/{admin,public}
    chown admin:admin /srv/samba/admin && chmod u=rwx,go=rx /srv/samba/admin
    chown nobody:nogroup /srv/samba/public && chmod u=rwx,go=rx /srv/samba/public

    # add user/set password
    USERNAME=$(${pkgs.gnused}/bin/sed -n 's/^username=\(.*\)/\1/p' ${config.sops.secrets.samba-ruylopez-admin-creds.path})
    PASSWORD=$(${pkgs.gnused}/bin/sed -n 's/^password=\(.*\)/\1/p' ${config.sops.secrets.samba-ruylopez-admin-creds.path})
    ${pkgs.samba4Full}/bin/smbpasswd -a "''${USERNAME}" <<EOF
    ''${PASSWORD}
    ''${PASSWORD}
    EOF

    echo "Finished Creating Samba Users"
  '';

  # avahi/mdns
  services.avahi = {
    enable = true;

    publish = {
      domain = true;
      enable = true;
      userServices = true;
    };
    nssmdns4 = true;
    openFirewall = true;
  };

  # disable lid switch
  services.logind.lidSwitch = "ignore";

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

  # gnupg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # system packages
  environment.systemPackages = with pkgs; [
    # resource monitor
    btop
    duf

    # networking
    nmap
    mtr
    dig
    tcpdump
    shadowsocks-rust
    lsof

    # dev
    gh

    # file utils
    zip
    unzip
    wget
    p7zip

    # misc
    fastfetch
  ];

  # locate
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly";
    pruneNames = [ ".snapshots" ]; # ignore snapshot directories
  };

  # git
  programs.git = {
    enable = true;
    prompt.enable = true;
  };

  # tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  # shells
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ bash zsh ];

  # users
  users.users.admin = {
    description = "Administrator";
    isNormalUser = true;
    uid = 1000;
    group = "admin";
    createHome = true;
    home = "/home/admin";
    shell = pkgs.bash;

    extraGroups = [
      "wheel" # enable sudo
      "mlocate" # allow non-root user to use mlocate
    ];

    hashedPasswordFile = config.sops.secrets.admin-hashed-user-pass.path;

    openssh.authorizedKeys.keyFiles = [
      ../../ssh-keys/grunfeld.pub
      ../../ssh-keys/ruylopez.pub
      ../../ssh-keys/najdorf.pub
      ../../ssh-keys/ipad.pub
      ../../ssh-keys/iphone.pub
    ];
  };
  users.groups.admin = {
    gid = 1000;
    members = [ "admin" ];
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
