{
  flake.modules.homeManager.sshfs = {pkgs, ...}: {
    home.packages = [pkgs.sshfs];
  };
}
