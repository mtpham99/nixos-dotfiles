# screenshot.nix

{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    libnotify # notif-send
    papirus-icon-theme # icons

    grim # screenshot
    slurp # region selector
    swappy # snapshot editor
    # wl-screenrec # screen recorder w/ hardware encoding
  ];

  home.file.".local/bin/screenshot.sh".text = ''
    #!/usr/bin/env sh

    time=$(date "+%d%b_%H-%M-%S")
    filename="''${time}.png"
    savedir="${config.xdg.userDirs.pictures}/screenshots"
    savepath="''${savedir}/''${filename}"

    notify() {
      notify-send \
        --hint=string:x-canonical-private-synchronous:shot-notify \
        --urgency=low \
        --expire-time 5000 \
        --icon "''${savepath}" \
        "Screenshot: ''${savepath}"
    }

    screenshot() {
      grim -g "$(slurp -d)" - | swappy -f - -o "''${savepath}"
      wl-copy < "''${savepath}"
    }

    screenshot && notify
  '';
}
