{ config, pkgs, pkgs-stable, lib, ... }:

{
  home.packages = [
    # Sound shite
    pkgs.reaper
    pkgs.lmms
    pkgs-stable.carla
    pkgs.vital
    pkgs.lsp-plugins

  ];

  home.sessionVariables = 
    let
      makePluginPath = format:
        (lib.makeSearchPath format [
          "$HOME/.nix-profile/lib"
          "/run/current-system/sw/lib"
          "/etc/profiles/per-user/$USER/lib"
        ])
        + ":$HOME/.${format}";
    in
  {
    DSSI_PATH = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH = makePluginPath "lv2";
    LXVST_PATH = makePluginPath "lxvst";
    VST_PATH = makePluginPath "vst";
    VST3_PATH = makePluginPath "vst3";
  };
}
