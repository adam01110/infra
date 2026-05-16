_: {
  perSystem = {pkgs, ...}: let
    inherit (builtins) attrValues;
  in {
    packages.text-preview = pkgs.writeShellApplication {
      # SPDX-License-Identifier: AGPL-3.0-or-later
      name = "text-preview";
      runtimeInputs =
        [
          pkgs.bat
        ]
        ++ attrValues {
          inherit
            (pkgs)
            # keep-sorted start
            file
            # keep-sorted end
            ;
        };
      text = ''
        path="''${1-}"

        if [ -z "$path" ]; then
          exit 0
        fi

        mime_info=$(file --brief --mime --dereference -- "$path")

        if [ "''${mime_info##*charset=}" != "binary" ]; then
          bat -n --color=always -- "$path" || file --brief --dereference -- "$path"
        else
          file --brief --dereference -- "$path"
        fi
      '';
    };
  };
}
