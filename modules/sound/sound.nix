{ config, pkgs, pkgsStable, lib, ... }:

let
  makePluginPath = format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ])
    + ":$HOME/.${format}";
  
  pluginLinkFarm = name: type: packages:
    pkgs.linkFarm name
      (builtins.concatLists (map (pkg:
        let
          basePath =
            if type == "lv2" then "${pkg}/lib/lv2"
            else if type == "vst3" then "${pkg}/lib/vst3"
            else throw "Unsupported plugin type: ${type}";
        in
          if builtins.pathExists basePath then
            map (bundle: {
              name = baseNameOf bundle;
              path = bundle;
            }) (builtins.attrValues (builtins.readDir basePath))
          else
            []
      ) packages));

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
    pkgs.pipewire.jack
    pkgs.a2jmidid
    qjackctl-pwjack
  ] ++ daw ++ vst3Plugins ++ lv2Plugins;

  home.file = {

    ".vst3".source = pluginLinkFarm "vst3-plugins" "vst3" vst3Plugins;
    ".lv2".source  = pluginLinkFarm "lv2-plugins" "lv2" lv2Plugins;

    ".config/REAPER/ColorThemes/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/sound/themes";
      recursive = true;
    };
  };

  systemd.user.services.a2jmidid = {
    Unit = {
      Description = "ALSA to JACK MIDI bridge";
      After = [ "pipewire.service" ];
      Wants = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = "${pkgs.coreutils}/bin/sh -c ''\
        export LD_LIBRARY_PATH=\"$(nix eval --raw nixpkgs#pipewire.jack)/lib\"; \
        a2jmidid -e''";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
