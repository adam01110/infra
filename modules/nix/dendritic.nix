{inputs, ...}: {
  flake-file.inputs = {
    # keep-sorted start
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    # keep-sorted end
  };

  imports = [
    # keep-sorted start
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-parts.flakeModules.modules
    # keep-sorted end
  ];
}
