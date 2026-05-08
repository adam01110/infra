{
  flake.modules.nixos.tlp = {lib, ...}: {
    services = {
      # Disable conflicting power management daemon.
      power-profiles-daemon.enable = lib.mkForce false;

      tlp = {
        enable = true;

        # Enable tlp power daemon for power-profiles-daemon compatibility.
        pd.enable = true;
      };
    };
  };
}
