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

  home.file.".config/git/".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/LycOS/dotfiles/git";
}
