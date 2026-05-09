{
  flake.modules.homeManager.lutris = {
    # keep-sorted start
    osConfig,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    bluetoothEnabled = osConfig.capabilities.bluetooth;
    inherit (osConfig.programs) steam;
  in {
    nixpkgs.overlays = [self.overlays.pkgs];

    programs.lutris = {
      enable = true;

      package = pkgs.lutris.override {
        inherit bluetoothEnabled;
        steamSupport = true;
      };

      # Add umu launcher for proton outside of steam.
      extraPackages = [pkgs.umu-launcher] ++ steam.extraPackages;

      # Proton and the package of steam form the system steam module.
      steamPackage = steam.package;
      protonPackages = steam.extraCompatPackages;
    };
  };
}
