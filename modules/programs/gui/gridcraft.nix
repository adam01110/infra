{
  flake.modules.homeManager.gridcraft = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.quriosity.gridcraft];
  };
}
