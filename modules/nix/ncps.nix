{lib, ...}: {
  flake.modules.nixos.ncps = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    cacheHost = "ncps.${vars.groundDomain}";
    cacheUrl = "https://${cacheHost}";
    uploadKeySecret = "nix_secret_keys/ncps-upload-1";

    ncpsPublicKey = "${cacheHost}:jhlVJBu6bD3n1MCG153qnMFXLNfzqh7aBDK/gRULvdc=";
  in {
    sops.secrets.${uploadKeySecret} = {};

    nix.settings = {
      secret-key-files = [config.sops.secrets.${uploadKeySecret}.path];
      substituters = mkForce [cacheUrl];
      trusted-public-keys = mkForce [ncpsPublicKey];
      trusted-substituters = mkForce [cacheUrl];
    };
  };
}
