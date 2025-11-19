{ config, ... }:

{
  home.file = {
    ".config/kanata" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/kanata/kanata";
      recursive = true;
    };
  };
}

