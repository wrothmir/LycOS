# /fonts/fonts.nix
{ pkgs }:

let
  fontDir = ./ttfs;  # relative path to folder containing TTFs
  lib = pkgs.lib;

  # list of fonts: use the exact filename of the TTF
  fontNames = [
    "Cuprum.ttf"
    "OpenSans-CondLight.ttf"
    "OpenSans-Italic.ttf"
    "PT_Sans-Narrow-Web-Regular.ttf"
    "SegoeUI.ttf"
    "SegUISB.ttf"
    "Share-Regular.ttf"
    "Roboto-Bold.ttf"
    "Roboto-Regular.ttf"
    "RobotoCondensed-Regular.ttf"
    "RobotoCondensed-Bold.ttf"
  ];

  makeFont = fileName: pkgs.runCommand (lib.strings.toLower (lib.strings.replaceStrings [".ttf"] [""] fileName)) {
    inherit fileName;
  } ''
    mkdir -p $out/share/fonts/truetype
    cp ${fontDir}/"${fileName}" $out/share/fonts/truetype/
  '';  
  localFonts = map makeFont fontNames;
  nixFonts = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.monoid
    pkgs.ipafont
    pkgs.kochi-substitute
  ];

in
localFonts ++ nixFonts
