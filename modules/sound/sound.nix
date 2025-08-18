{ config, pkgs, pkgsStable, lib, ... }:

let
  makePluginPath = format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ])
    + ":$HOME/.${format}";
  
  pluginLinks = pkgs: type:
    lib.concatMap (pkg:
      let
        dir =
          if type == "vst3" then "${pkg}/lib/vst3"
          else if type == "vst" then "${pkg}/lib/vst"
          else if type == "lv2" then "${pkg}/lib/lv2"
          else throw "Unsupported plugin type: ${type}";
        contents = builtins.attrNames (builtins.readDir dir);
      in map (name: {
        name = name;
        path = "${dir}/${name}";
      }) contents
    ) pkgs;

  sitala = pkgs.stdenv.mkDerivation rec {
    pname = "sitala";
    version = "1.0";

    src = pkgs.fetchurl {
      url = "https://decomposer.de/sitala/releases/sitala-1.0_amd64.deb";
      sha256 = "0cz33jsssh6g9gqzvawvfi80fjcd13qf8yhl7f3nqx0rdwk4hl6v"; 
    };

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.glibc
      pkgs.freetype
      pkgs.curlWithGnuTls
      pkgs.stdenv.cc.cc.lib
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.alsa-lib
    ];

    unpackPhase = ''
      dpkg-deb -x "$src" .
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/vst
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons

      cp usr/bin/sitala $out/bin/sitala
      cp -r usr/lib/lxvst/* $out/lib/vst/
      cp -r usr/share/applications/* $out/share/applications/
      cp -r usr/share/icons/* $out/share/icons/
    '';

    meta = with lib; {
      description = "Sitala drum sampler VST/AU plugin";
      homepage = "https://decomposer.de/sitala/";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
    };
  };

  qjackctl-pwjack = pkgs.writeShellScriptBin "qjackctl" ''
    exec pw-jack ${pkgs.qjackctl}/bin/qjackctl "$@"
  '';
  reaper-pwjack = pkgs.writeShellScriptBin "reaper" ''
    exec pw-jack ${pkgs.reaper}/bin/reaper "$@"
  '';

  # VST3 compatible plugins
  vst3Plugins = [
    pkgs.vital
    pkgs.lsp-plugins
    pkgs.cardinal
    pkgs.odin2
    pkgs.surge-XT
  ];

  # VST compatible plugins
  vstPlugins = [
    sitala
  ];

  # LV2 compatible plugins
  lv2Plugins = [
    pkgs.x42-avldrums
    pkgs.drumgizmo
  ];

  daw = [
    reaper-pwjack
  ];
in
{  
  home.sessionVariables = {
    DSSI_PATH = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH = makePluginPath "lv2";
    LXVST_PATH = makePluginPath "lxvst";
    VST_PATH = makePluginPath "vst";
    VST3_PATH = makePluginPath "vst3";
  };

  home.packages = [
    pkgs.alsa-lib
    pkgs.pipewire.jack
    pkgs.a2jmidid
    pkgs.decent-sampler
    qjackctl-pwjack
  ] ++ daw ++ vst3Plugins ++ lv2Plugins;

  home.file = {

    ".vst3".source = pkgs.linkFarm "vst3-plugins" (pluginLinks vst3Plugins "vst3");
    ".vst".source  = pkgs.linkFarm "vst-plugins" (pluginLinks vstPlugins "vst");
    ".lv2".source  = pkgs.linkFarm "lv2-plugins" (pluginLinks lv2Plugins "lv2");

    ".config/REAPER/ColorThemes/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/sound/themes";
      recursive = true;
    };
  };

  systemd.user.services.a2jmidid = {
    Unit = {
      Description = "ALSA to JACK MIDI bridge";
      After = [ "pipewire.service" "pipewire-pulse.service" ];
      Wants = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = "${pkgs.a2jmidid}/bin/a2jmidid -e";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
