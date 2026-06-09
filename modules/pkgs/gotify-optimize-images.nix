{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.gotify-optimize-images = writeShellApplication {
      name = "gotify-optimize-images";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        imagemagick
        optipng
        # keep-sorted end
      ];
      text = ''
        set -e
        DATA=/var/lib/gotify/data
        for FILE in "$DATA"/images/*; do
          if [ "$FILE" -nt "$DATA"/images-optimized ]; then
            EXT=$(echo "''${FILE##*.}" | tr '[:upper:]' '[:lower:]')
            if [ "$EXT" = png ] || [ "$EXT" = jpg ] || [ "$EXT" = jpeg ] || [ "$EXT" = gif ]; then
              convert "$FILE" -resize "512>" "$FILE"
            fi
            if [ "$EXT" = png ]; then
              optipng "$FILE"
            fi
          fi
        done
        touch "$DATA"/images-optimized
      '';
    };
  };
}
