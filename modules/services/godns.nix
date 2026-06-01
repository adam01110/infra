{self, ...}: {
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
    imports = [self.modules.nixos.sops];

    sops.secrets = {
      # keep-sorted startr
      "godns/login_token" = {};
      "godns/password" = {};
      # keep-sorted end
    };

    services.godns = {
      enable = true;

      settings = {
        provider = "Porkbun";

        domains = let
          mkDomain = domain: {
            domain_name = domain;
            sub_domains = ["@"];
          };
        in [
          # keep-sorted start
          (mkDomain orbitDomain)
          (mkDomain groundDomain)
          # keep-sorted end
        ];

        resolver = "8.8.8.8";
        ip_type = "IPv4";
        interval = 300;

        ip_urls = [
          # keep-sorted start
          "https://api.ip.sb/ip"
          "https://api.ipify.org"
          "https://myip.biturl.top"
          "https://api-ipv4.ip.sb/ip"
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
