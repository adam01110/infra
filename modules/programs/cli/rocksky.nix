{
  flake.aspects.rocksky.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.rocksky-cli];
  };
}
