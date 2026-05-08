{self, ...}: {
  flake.modules.nixos.podman = {
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
      mkEnableOption
      mkIf
      # keep-sorted end
      ;
    inherit (vars) username;

    cfgAutoPrune = config.optServices.podman.autoPrune.enable;
  in {
    imports = [self.modules.generic.vars];

    options.optServices.podman.autoPrune.enable = mkEnableOption "Enable podman auto-prune.";

    virtualisation = {
      podman = {
        # Enable podman service and tooling.
        enable = true;
        # Expose docker-compatible socket for tooling that expects dockerd.
        dockerSocket.enable = true;

        # Clean up unused images/containers regularly.
        autoPrune = mkIf cfgAutoPrune {
          enable = true;

          flags = [
            # keep-sorted start
            "--all"
            "--force"
            # keep-sorted end
          ];
        };
      };

      # Disable the podman compose warning about external command execution.
      containers.containersConf.settings.engine.compose_warning_logs = false;
    };

    # Enable the usage of compose files with podman.
    environment.systemPackages = [pkgs.podman-compose];

    # Add user to the podman group.
    users.users.${username}.extraGroups = ["podman"];
  };
}
