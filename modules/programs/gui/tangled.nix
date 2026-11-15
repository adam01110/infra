{
  flake.aspects.tangled.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.tg];
  };
}
