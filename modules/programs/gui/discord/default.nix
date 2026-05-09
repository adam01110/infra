{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nixcord = {
    url = "github:kaylorben/nixcord";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.discord = {config, ...}: {
    imports = [
      # keep-sorted start
      inputs.nixcord.homeModules.nixcord
      self.modules.generic.vars
      # keep-sorted end
    ];

    # keep-sorted start block=yes newline_separated=yes
    programs.nixcord = {
      enable = true;
      discord.enable = false;

      equibop = {
        enable = true;
        configDir = "${config.xdg.configHome}/equibop";
      };
    };
    # keep-sorted end
  };
}
