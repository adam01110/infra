_: {
  flake.modules.homeManager.tangled = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.tg];
  };
}
