{
  flake.modules.nixos.godns = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (vars)
      # keep-sorted start
      groundDomain
      orbitDomain
      # keep-sorted end
      ;

    secrets = config.sops.secrets;
  in {
    sops.secrets = {
      # keep-sorted start
      "godns/login_token" = {};
      "godns/password" = {};
      # keep-sorted end
    };

    services.godns = {
      enable = true;

      settings = {
        provider = "Porkbun";
        login_token_file = "$CREDENTIALS_DIRECTORY/login_token";
        password_file = "$CREDENTIALS_DIRECTORY/password";

        domains = let
          mkDomain = domain: {
            domain_name = domain;
            sub_domains = ["@"];
          };
        in [
          # keep-sorted start
          (mkDomain groundDomain)
          (mkDomain orbitDomain)
          # keep-sorted end
        ];

        resolver = "8.8.8.8";
        ip_type = "IPv4";
        interval = 300;

        ip_urls = [
          # keep-sorted start
          "https://api-ipv4.ip.sb/ip"
          "https://api.ip.sb/ip"
          "https://api.ipify.org"
          "https://myip.biturl.top"
          # keep-sorted end
        ];
      };

      loadCredential = [
        # keep-sorted start
        "login_token:${secrets."godns/login_token".path}"
        "password:${secrets."godns/password".path}"
        # keep-sorted end
      ];
    };
  };
}
