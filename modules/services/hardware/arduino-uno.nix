{
  flake.modules.nixos.arduino-uno = {pkgs, ...}: let
    inherit (pkgs) writeTextDir;
  in {
    # Tag serial devices before 73-seat-late.rules grants active-seat access.
    services.udev.packages = [
      (writeTextDir "lib/udev/rules.d/70-arduino-uno.rules" ''
        SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", TAG+="uaccess"
      '')
    ];
  };
}
