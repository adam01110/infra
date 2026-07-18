{
  flake.modules.nixos.anubis = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) toJSON;

    inherit (vars) groundDomain;

    anubisUser = config.services.anubis.instances.traefik.user;
    secrets = config.sops.secrets;
    sopsPlaceholder = config.sops.placeholder;
    templates = config.sops.templates;
  in {
    sops = {
      secrets = {
        "anubis/signing_key" = {
          mode = "0400";
          owner = anubisUser;
          restartUnits = ["anubis-traefik.service"];
        };

        "anubis/valkey_password" = {};
      };

      templates."anubis-traefik-policy.json" = {
        mode = "0400";
        owner = anubisUser;
        restartUnits = ["anubis-traefik.service"];
        content = toJSON {
          bots = [
            {import = "(data)/meta/default-config.yaml";}
          ];

          status_codes = {
            CHALLENGE = 200;
            DENY = 403;
          };

          store = {
            backend = "valkey";
            parameters.url = "redis://:${sopsPlaceholder."anubis/valkey_password"}@euclid.wg:6379/0";
          };
        };
      };
    };

    services.anubis.instances.traefik.settings = {
      BIND = "127.0.0.1:8923";
      BIND_NETWORK = "tcp";

      COOKIE_DOMAIN = groundDomain;
      ED25519_PRIVATE_KEY_HEX_FILE = secrets."anubis/signing_key".path;
      POLICY_FNAME = templates."anubis-traefik-policy.json".path;

      PUBLIC_URL = "https://anubis.${groundDomain}";
      REDIRECT_DOMAINS = "${groundDomain},*.${groundDomain}";
      TARGET = " ";

      SERVE_ROBOTS_TXT = true;
    };

    systemd.services.anubis-traefik = {
      after = ["sops-install-secrets.service"];
      wants = ["sops-install-secrets.service"];
    };
  };
}
