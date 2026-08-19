{
  flake.modules.homeManager.ai-usagebar = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.adam0.ai-usagebar];
  };
}
