{
  flake.modules.homeManager.rocksky = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.rocksky-cli];
  };
}
