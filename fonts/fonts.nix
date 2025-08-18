# /fonts/fonts.nix
{ pkgs }:

let
  fontDir = ./ttfs;  # relative path to folder containing TTFs

  # list of fonts: use the exact filename of the TTF
  fontNames = [
    "Cuprum"
    "OpenSans-CondLight"
    "OpenSans-Italic"
    "PT_Sans-Narrow-Web-Regular"
    "SegoeUI"
    "SegUISB"
    "Share-Regular"
  ];

  makeFont = fileName: pkgs.stdenv.mkDerivation {
    pname = builtins.toLower fileName;
    version = "1.0";
    src = "${fontDir}/${fileName}.ttf";
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp "$src" $out/share/fonts/truetype/
    '';
  };
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
