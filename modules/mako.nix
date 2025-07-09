{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    defaultTimeout = 4000;
    backgroundColor = "#fbf1c7";
    textColor="#000000";
    borderColor="#000000";
    borderSize=3;
    borderRadius=5;
  };
}
