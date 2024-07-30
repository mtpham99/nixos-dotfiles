# psd.nix
# profile sync daemon

{ pkgs, ... }:

{
  services.psd = {
    enable = true;
    resyncTimer = "1hr";
  };
}
