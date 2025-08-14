{ config, lib, pkgs, ... }:

let
  appName = "FModStudio"; # Change to match your app
  appImagePath = ./application/fmodstudio.AppImage; # Path relative to flake.nix
  iconPath = ./application/fmodstudio.svg; # Path to your SVG icon

  fmodstudio = pkgs.makeDesktopItem {
    name = appName;
    exec = ''${appImagePath}''; # Use absolute path or install location
    icon = iconPath;
    desktopName = appName;
    categories = [ "Utility" ];
    comment = "FMod Studio";
    startupWMClass = appName;
  };
in
{
  home.file.".local/bin/fmodstudio.AppImage".source = appImagePath;
  home.file.".local/bin/fmodstudio.AppImage".executable = true;
  home.packages = [
    fmodstudio 
  ];
}

