{inputs, ...}: {
  flake-file.inputs = {
    # keep-sorted start
    flake-aspects.url = "github:denful/flake-aspects";
    flake-file.url = "github:denful/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    # keep-sorted end
  };

  imports = [
    # keep-sorted start
    inputs.flake-aspects.flakeModule
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-parts.flakeModules.modules
    # keep-sorted end
  ];
}
