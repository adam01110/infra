{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    home = config.home.homeDirectory;
    jsonFormat = pkgs.formats.json {};
  in {
    home.file.".pi/agent/extensions/pi-permission-system/config.json".source = jsonFormat.generate "pi-permission-system.json" {
      permission = {
        # Tools are unrestricted while they operate inside the launch cwd.
        "*" = "allow";

        # Require confirmation before loading high-impact optional workflows.
        skill = {
          "*" = "allow";
          "computer-use-linux" = "ask";
          "simplify" = "ask";
        };

        # Outside the cwd, expose only roots mirrored by the jail.
        external_directory_read = {
          "*" = "deny";
          "/etc/profiles/*" = "allow";
          "/nix/store/*" = "allow";
          "/run/current-system/*" = "allow";
          "${home}/.local/state/nix/profile/*" = "allow";
          "${home}/.nix-profile/*" = "allow";
          "${home}/Infra/*" = "allow";
          "${home}/Projects/*" = "allow";
        };

        # Require confirmation before writing outside the launch directory.
        external_directory_write = "ask";
      };
    };
  };
}
