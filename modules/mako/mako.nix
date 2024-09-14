{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    defaultTimeout = 4000;
    backgroundColor = "#fbf1c7";
  };
}
