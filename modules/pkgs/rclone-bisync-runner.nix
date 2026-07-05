{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.rclone-bisync-runner = writeShellApplication {
      name = "rclone-bisync-runner";

      runtimeInputs = with pkgs; [
        # keep-sorted start
        coreutils
        rclone
        # keep-sorted end
      ];

      text = ''
        set -eu

        : "''${LOCAL_PATH:?LOCAL_PATH is required}"
        : "''${REMOTE_PATH:?REMOTE_PATH is required}"
        : "''${WORK_DIR:?WORK_DIR is required}"

        initialized_marker="$WORK_DIR/initialized"

        mkdir -p "$LOCAL_PATH" "$WORK_DIR"

        rclone_args=(
          bisync
          "$LOCAL_PATH"
          "$REMOTE_PATH"
          --workdir "$WORK_DIR"
          --create-empty-src-dirs
          --resilient
          --recover
          --max-lock 2m
          --conflict-resolve newer
          --verbose
        )

        rclone mkdir "$REMOTE_PATH"

        if [ -e "$initialized_marker" ]; then
          rclone "''${rclone_args[@]}"
        else
          rclone "''${rclone_args[@]}" --resync-mode newer
          touch "$initialized_marker"
        fi
      '';
    };
  };
}
