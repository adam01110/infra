{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake?ref=beta";
      inputs = {
        # keep-sorted start
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        # keep-sorted end
      };
    };
  };

  flake.modules.homeManager.zen = {
    imports = [
      inputs.zen-browser.homeModules.beta
      self.modules.homeManager.stylixBase
    ];

    programs.zen-browser.enable = true;

    stylix.targets.zen-browser.profileNames = ["default"];
  };
}
