{
  # keep-sorted start
  inputs,
  # keep-sorted end
  ...
}: {
  flake-file.inputs.nixcord = {
    url = "github:kaylorben/nixcord";
    inputs.flake-parts.follows = "flake-parts";
  };

  flake.modules.homeManager.discord = {config, ...}: {
    imports = [inputs.nixcord.homeModules.nixcord];

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
