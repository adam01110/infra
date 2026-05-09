{
  perSystem = {pkgs, ...}: let
    inherit (builtins) attrValues;
    inherit (pkgs) writeShellApplication;
  in {
    packages.os-age = writeShellApplication {
      name = "os-age";
      runtimeInputs = attrValues {
        inherit
          (pkgs)
          # keep-sorted start
          coreutils
          # keep-sorted end
          ;
      };
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
