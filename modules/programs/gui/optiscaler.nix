{
  flake.modules.homeManager.optiscaler = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.optiscaler-client];
  };
}
