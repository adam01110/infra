{
  flake.aspects.sshfs.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.sshfs];
  };
}
