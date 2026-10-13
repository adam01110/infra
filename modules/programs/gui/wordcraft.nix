{
  flake.modules.homeManager.wordcraft = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.quriosity.wordcraft];
  };
}
