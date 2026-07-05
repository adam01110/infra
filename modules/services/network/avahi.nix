{
  flake.modules.nixos.avahi = {
    # mDNS/DNS-SD discovery for the local network.
    services.avahi = {
      enable = true;

      # keep-sorted start numeric=yes
      nssmdns4 = true;
      nssmdns6 = true;
      # keep-sorted end
    };
  };
}
