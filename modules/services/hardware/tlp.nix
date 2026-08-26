{
  flake.modules.nixos.tlp = {lib, ...}: let
    inherit (lib) mkForce;
  in {
    services = {
      # Disable conflicting power management daemon.
      power-profiles-daemon.enable = mkForce false;

      tlp = {
        enable = true;

        # Enable tlp power daemon for power-profiles-daemon compatibility.
        pd.enable = true;
      };
    };
  };
}
