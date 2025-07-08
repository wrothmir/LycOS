{ config, pkgs, ... }:

{
  home.shellAliases = {
    g = "git";
    gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
    gs = "git status";
    gc = "git commit";
    gp = "git push";
    gu = "git pull";
    gl = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'";
    gt = "git tag";
    gb = "git branch";
    gi = "git init";
    ga = "git add";
    gap = "git add --patch";
    gds = "git diff --staged";
    gcl = "git clone";
    gsw = "git switch";
  };

  home.file.".config/git/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/git/config-git/config";
  home.file.".config/git/ignore".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/git/config-git/ignore";
  home.file.".config/git/template".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/modules/git/config-git/template";
}
