{
  flake.modules.homeManager.lutris = {
    # keep-sorted start
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (osConfig.programs) steam;
  in {
    programs.lutris = {
      enable = true;

      package = pkgs.lutris;

      # Add umu launcher for proton outside of steam.
      extraPackages = [pkgs.umu-launcher] ++ steam.extraPackages;

      # Proton and the package of steam form the system steam module.
      steamPackage = steam.package;
      protonPackages = steam.extraCompatPackages;
    };
  };
}
