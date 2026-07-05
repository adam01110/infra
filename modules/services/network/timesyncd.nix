{
  flake.modules.nixos.timesyncd = {
    services.timesyncd.servers = [
      # keep-sorted start numeric=yes
      "server 0.pool.ntp.org"
      "server 1.pool.ntp.org"
      "server 2.pool.ntp.org"
      "server 3.pool.ntp.org"
      # keep-sorted end
    ];
  };
}
