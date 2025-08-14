{ config, pkgs, pkgsStable, lib, ... }:

{
  home.packages = [
    # Sound shite
    pkgs.reaper
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

  home.file = {
    ".config/REAPER/ColorThemes/" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/sound/themes";
      recursive = true;
    };
  };
}
