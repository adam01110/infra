{inputs, ...}: {
  flake-file.inputs.authentik-nix = {
    url = "github:nix-community/authentik-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  flake.modules.nixos.authentik = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) groundDomain;
  in {
    imports = [inputs.authentik-nix.nixosModules.default];

    sops = {
      secrets = {
        # keep-sorted start
        "authentik/proxy_token" = {};
        "authentik/secret_key" = {};
        # keep-sorted end
      };

      templates = {
        "authentik.env".content = ''
          AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
        '';

        "authentik-proxy.env".content = ''
          AUTHENTIK_HOST=https://authentik.${groundDomain}
          AUTHENTIK_TOKEN=${config.sops.placeholder."authentik/proxy_token"}
        '';
      };
    };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.templates."authentik.env".path;

        settings = {
          avatars = "gravatar";

          # Disable unrequired features.
          disable_startup_analytics = true;
          disable_update_check = true;
          error_reporting.enabled = false;
        };
      };

      authentik-proxy = {
        enable = true;
        environmentFile = config.sops.templates."authentik-proxy.env".path;
      };
    };
  };
}
