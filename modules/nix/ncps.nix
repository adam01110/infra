{lib, ...}: {
  flake.modules.nixos.ncps = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkBefore;

    cacheHost = "ncps.${vars.groundDomain}";
    cacheUrl = "https://${cacheHost}?priority=-10";
    uploadKeySecret = "nix_ncps_upload_secret_key";

    ncpsPublicKey = "${cacheHost}:jhlVJBu6bD3n1MCG153qnMFXLNfzqh7aBDK/gRULvdc=";
  in {
    sops.secrets.${uploadKeySecret} = {};

    nix.settings = {
      secret-key-files = [config.sops.secrets.${uploadKeySecret}.path];
      substituters = mkBefore [cacheUrl];
      trusted-public-keys = mkBefore [ncpsPublicKey];
      trusted-substituters = mkBefore [cacheUrl];
    };
  };
}
