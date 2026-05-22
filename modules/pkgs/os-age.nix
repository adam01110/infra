{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.os-age = writeShellApplication {
      name = "os-age";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        birth_install="$(stat -c %W /)"
        current="$(date +%s)"
        time_progression="$((current - birth_install))"
        days_difference="$((time_progression / 86400))"

        echo "$days_difference days"
      '';
    };
  };
}
