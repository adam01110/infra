{
  flake.modules.nixos.optiscaler = {
    nix.settings = let
      cache = "https://uriotv.cachix.org";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["uriotv.cachix.org-1:goitmxx1/DXbyeFNubk9Dmp9nvg4V188Wvu4CdrRsyI="];
    };
  };

  flake.modules.homeManager.optiscaler = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.uriotv.optiscaler-client];
  };
}
