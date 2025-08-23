{ config, pkgs, pkgsStable, lib, ... }:

let
  
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

  qjackctl-pwjack = pkgs.writeShellScriptBin "qjackctl" ''
    exec pw-jack ${pkgs.qjackctl}/bin/qjackctl "$@"
  '';
  reaper-pwjack = pkgs.writeShellScriptBin "reaper" ''
    exec pw-jack ${pkgs.reaper}/bin/reaper "$@"
  '';

  hydrogen-pwjack = pkgs.writeShellScriptBin "hydrogen" ''
    exec pw-jack ${pkgs.hydrogen}/bin/hydrogen "$@"
  '';

  # VST3 compatible plugins
  vst3Plugins = [
    pkgs.vital
    pkgs.lsp-plugins
    pkgs.cardinal
    pkgs.odin2
    pkgs.surge-XT
  ];

  # LV2 compatible plugins
  lv2Plugins = [
    pkgs.x42-avldrums
    pkgs.x42-plugins
    pkgs.x42-gmsynth
    pkgs.drumgizmo
  ];

  standalone = [
    #pkgs.reaper
    #pkgs.qjackctl
    #pkgs.hydrogen
    pkgs.seq66

    qjackctl-pwjack
    reaper-pwjack
    hydrogen-pwjack
  ];
in
{  

  home.packages = [
    pkgs.alsa-lib
    pkgs.pipewire.jack
    pkgs.a2jmidid
    pkgs.decent-sampler

    pkgs.distrho-ports

    pkgs.yabridge
    pkgs.yabridgectl
    pkgs.wineWowPackages.stable

  ] ++ standalone ++ vst3Plugins ++ lv2Plugins;

  home.file = {

    ".vst3".source = pkgs.linkFarm "vst3-plugins" (pluginLinks vst3Plugins "vst3");
    ".lv2".source  = pkgs.linkFarm "lv2-plugins" (pluginLinks lv2Plugins "lv2");

    ".config/REAPER/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/sound/reaper/";
      recursive = true;
    };

    ".config/yabridgectl/config.toml".text = ''
      plugin_dirs = ['/home/wrothmir/.win-vst']
      vst2_location = 'centralized'
      no_verify = false
      blacklist = []
    '';
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
