{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs-crowdsec.url = "github:TornaxO7/nixpkgs/saltsprint";
    nixpkgs-crowdsec-blocklist-import.url = "github:gaelj/nixpkgs/init-crowdsec-blocklist-import";
  };

  flake.overlays.crowdsec = final: _prev: let
    inherit (final.stdenv.hostPlatform) system;
    crowdsecPkgs = inputs.nixpkgs-crowdsec.legacyPackages.${system};
  in {
    inherit
      (crowdsecPkgs)
      # keep-sorted start
      crowdsec
      crowdsec-firewall-bouncer
      # keep-sorted end
      ;
  };
}
