{
  flake.modules.homeManager.btop = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkOption types;

    inherit (config.programs.btop) gpuBackends;
    hasCuda = lib.elem "cuda" gpuBackends;
    hasRocm = lib.elem "rocm" gpuBackends;

    # Pick gpu-aware version of btop.
    btopPackage =
      if hasCuda && hasRocm
      then
        pkgs.btop.override {
          cudaSupport = true;
          rocmSupport = true;
        }
      else if hasCuda
      then pkgs.btop-cuda
      else if hasRocm
      then pkgs.btop-rocm
      else pkgs.btop;
  in {
    options.programs.btop.gpuBackends = mkOption {
      description = "Select GPU backends to enable in btop.";

      type = types.listOf (
        types.enum [
          # keep-sorted start
          "cuda"
          "rocm"
          # keep-sorted end
        ]
      );
      default = [];
    };

    config.programs.btop = {
      enable = true;
      package = btopPackage;

      settings = {
        # keep-sorted start newline_separated=yes
        # Hide btrfs subvolume mounts from disk widgets.
        disks_filter = "exclude=/home /nix /root /var/cache /var/lib /var/log";

        # Disable logging.
        log_level = "DISABLED";

        # Disable rounded corners for consistent flat design.
        rounded_corners = false;

        # Update frequency of 1000ms balances responsiveness and performance.
        update_ms = 1000;

        # Match vim-style navigation.
        vim_keys = true;
        # keep-sorted end

        # Process display settings.
        # keep-sorted start
        proc_aggregate = true;
        proc_gradient = false;
        proc_tree = true;
        # keep-sorted end

        # Memory display settings.
        # keep-sorted start
        mem_graphs = true;
        swap_disk = false;
        # keep-sorted end
      };
    };
  };
}
