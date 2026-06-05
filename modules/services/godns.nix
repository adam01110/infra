{self, ...}: {
  flake.overlays.godns = _final: prev: let
    version = "3.4.1";

    src = prev.fetchFromGitHub {
      owner = "TimothyYe";
      repo = "godns";
      tag = "v${version}";
      hash = "sha256-LdMeb7pFYj+6HdUBgFkS756oox2HRgkwlHz65SgJoqY=";
    };

    packageLock = prev.fetchurl {
      url = "https://raw.githubusercontent.com/tbutter/nixpkgs/a761abce85346f7de12fc7f2e792e6c7230f5217/pkgs/by-name/go/godns/package-lock.json";
      hash = "sha256-Lp3M2Ql4+Mr3qRdAqFAIE54BUwEIJWlsKiArZT41TXA=";
    };
  in {
    # Pin until NixOS/nixpkgs#518713 is merged.
    godns = prev.godns.overrideAttrs (oldAttrs: {
      inherit packageLock src version;

      ldflags = [
        "-s"
        "-w"
        "-X main.Version=${version}"
        "-buildid="
      ];

      npmDeps = prev.fetchNpmDeps {
        src = prev.stdenv.mkDerivation {
          name = "godns-web-src";
          inherit packageLock;
          src = "${src}/web";

          dontUnpack = true;
          installPhase = ''
            mkdir $out
            cp -r $src/* $out
            chmod +w $out
            cp $packageLock $out/package-lock.json
          '';
        };
        hash = "sha256-f8BU3HfQX9E+AFpXvNjRJNwT5nX1WwyinMRb7DP0FYU=";
      };

      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          cp ${packageLock} web/package-lock.json
          substituteInPlace internal/provider/porkbun/porkbun_handler.go \
            --replace-fail 'ID     string `json:"id,omitempty"`' 'ID     interface{} `json:"id,omitempty"`'
        '';

      __darwinAllowLocalNetworking = true;
    });
  };

  flake.modules.nixos.godns = {
    # keep-sorted start
    config,
    pkgs,
    self,
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
    nixpkgs.overlays = [self.overlays.godns];

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

    systemd.services.godns.environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };
}
