{
  flake.modules.homeManager.nvtop = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      genAttrs
      head
      mkOption
      tail
      types
      # keep-sorted end
      ;

    gpuTypes = [
      # keep-sorted start
      "amd"
      "apple"
      "intel"
      "msm"
      "nvidia"
      "panfrost"
      "panthor"
      "v3d"
      # keep-sorted end
    ];
  in {
    options.nvtop.types = mkOption {
      type = types.listOf (types.enum gpuTypes);
      default = [];
      description = "Choose which GPU types to monitor with nvtop.";
    };

    # Override enables multiple gpu backends in single nvtop instance.
    config.home.packages = let
      selectedTypes = config.nvtop.types;
    in
      if selectedTypes == []
      then []
      else let
        primaryType = head selectedTypes;
        extraTypes = tail selectedTypes;
        basePackage = pkgs.nvtopPackages.${primaryType};
        backends = genAttrs selectedTypes (_: true);
      in [
        (
          if extraTypes == []
          then basePackage
          else basePackage.override backends
        )
      ];
  };
}
