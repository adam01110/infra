_: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.gotify-install-plugins = writeShellApplication {
      name = "gotify-install-plugins";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        curl
        # keep-sorted end
      ];
      text = ''
        set -eu

        plugin_dir="$1"
        oidc_url="$2"
        shift 2

        for attempt in $(seq 1 60); do
          if curl --fail --silent --show-error --max-time 5 "$oidc_url" >/dev/null; then
            break
          fi

          if [ "$attempt" -eq 60 ]; then
            exit 1
          fi

          sleep 2
        done

        mkdir -p "$plugin_dir"

        for spec in "$@"; do
          src=''${spec%%:*}
          dest=''${spec##*:}
          install -Dm755 "$src" "$plugin_dir/$dest"
        done

        for f in "$plugin_dir"/*.so; do
          [ -e "$f" ] || continue
          base=''${f##*/}
          found=0
          for spec in "$@"; do
            dest=''${spec##*:}
            if [ "$base" = "$dest" ]; then
              found=1
              break
            fi
          done
          if [ "$found" -eq 0 ]; then
            rm -f "$f"
          fi
        done

        chown -R gotify:gotify "$plugin_dir"
      '';
    };
  };
}
