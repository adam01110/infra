{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake = {
    homeModules = self.modules.homeManager;

    modules.nixos.home-manager = {
      # keep-sorted start
      config,
      pkgs,
      vars,
      # keep-sorted end
      ...
    }: let
      inherit (vars) username;
    in {
      imports = [
        # keep-sorted start
        inputs.home-manager.nixosModules.home-manager
        self.modules.generic.vars
        # keep-sorted end
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit
            # keep-sorted start
            inputs
            pkgs
            self
            vars
            # keep-sorted end
            ;
        };

        startAsUserService = true;
        backupCommand = "${pkgs.trash-cli}/bin/trash";

        users.${username} = {lib, ...}: let
          inherit (lib.hm.dag) entryAfter;
        in {
          # Refresh removed units while the user manager is still starting.
          home.activation.reloadStartingSystemd = entryAfter ["reloadSystemd"] ''
            systemdStatus=$(${pkgs.systemd}/bin/systemctl --user is-system-running 2>&1 || true)
            if [[ $systemdStatus == starting ]]; then
              run ${pkgs.systemd}/bin/systemctl --user daemon-reload
            fi
          '';

          home = {
            inherit username;
            enableNixpkgsReleaseCheck = false;
            homeDirectory = "/home/${username}";

            # Align home manager state version with the system.
            inherit (config.system) stateVersion;
          };
        };
      };
    };
  };
}
