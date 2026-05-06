{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.tuigreet = {
    url = "github:notashelf/tuigreet";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # keep-sorted start block=yes newline_separated=yes
  flake.modules.nixos.tuigreet = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    inherit (vars) username;
    tomlFormat = pkgs.formats.toml {};
  in {
    imports = [self.modules.generic.vars];

    # keep-sorted start block=yes newline_separated=yes
    environment = {
      # Generate tuigreet configuration.
      etc."tuigreet/config.toml".source = let
        # keep-sorted start
        hyprland = getExe' config.programs.hyprland.package "start-hyprland";
        uwsm = getExe config.programs.uwsm.package;
        # keep-sorted end
      in
        tomlFormat.generate "tuigreet-config.toml" {
          # keep-sorted start block=yes newline_separated=yes
          display = {
            show_time = true;
            greeting = "authentication required.";
            time_format = "%Y-%m-%d %H:%M:%S";
          };

          layout = {
            # keep-sorted start
            container_padding = 1;
            prompt_padding = 1;
            window_padding = 1;
            # keep-sorted end
          };

          power = {
            use_setsid = false;
            shutdown = "systemctl poweroff";
            reboot = "systemctl reboot";
          };

          remember = {
            username = true;
            default_user = username;
          };

          secret.mode = "characters";

          session = {
            command = "${uwsm} start -eD Hyprland -- ${hyprland}";
            sessions_dirs = [];
            xsessions_dirs = [];
          };

          theme = {
            # keep-sorted start
            action = "white";
            border = "blue";
            button = "green";
            container = "black";
            greet = "white";
            input = "white";
            prompt = "blue";
            text = "white";
            time = "green";
            title = "white";
            # keep-sorted end
          };
          # keep-sorted end
        };
    };

    services.greetd = {
      enable = true;

      # Required by nixpkgs' greetd module for TTY greeters such as tuigreet.
      useTextGreeter = true;
      settings.default_session.command = getExe pkgs.tuigreet;
    };

    nixpkgs.overlays = [self.overlays.tuigreet];
    # keep-sorted end
  };

  flake.overlays.tuigreet = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;

  in {
    inherit (inputs.tuigreet.packages.${system}) tuigreet;
  };
  # keep-sorted end
}
