# brave.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [ brave ];

  # add desktop entry to use socks5 proxy
  xdg.desktopEntries.Brave-proxy = {
    type = "Application";
    name = "Brave Web Browser (socks5 127.0.0.1:1081)";
    genericName = "Web Browser";
    icon = "brave-browser";
    exec = "brave --proxy-server=127.0.0.1:1081 %U";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "application/pdf" "application/rdf+xml" "application/rss+xml" "application/xhtml+xml" "application/xhtml_xml" "application/xml" "image/gif" "image/jpeg" "image/png" "image/webp" "text/html" "text/xml" "x-scheme-handler/http" "x-scheme-handler/https" "x-scheme-handler/ipfs" "x-scheme-handler/ipns" ];
  };
}
