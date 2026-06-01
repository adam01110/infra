{
  flake.modules.nixos.podman = {
    # keep-sorted start
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    virtualisation = {
      podman = {
        # Enable podman service and tooling.
        enable = true;
        # Expose docker-compatible socket for tooling that expects dockerd.
        dockerSocket.enable = true;
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
