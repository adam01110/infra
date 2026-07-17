{
  flake.modules.homeManager.pi = {lib, ...}: let
    inherit
      (builtins)
      # keep-sorted start
      pathExists
      readDir
      # keep-sorted end
      ;
    inherit
      (lib)
      # keep-sorted start
      filterAttrs
      mapAttrs'
      nameValuePair
      # keep-sorted end
      ;

    skills = filterAttrs (
      name: type: type == "directory" && pathExists (./. + "/${name}/SKILL.md")
    ) (readDir ./.);
  in {
    home.file =
      mapAttrs' (
        name: _:
          nameValuePair ".agents/skills/${name}" {
            source = ./. + "/${name}";
            recursive = true;
          }
      )
      skills;
  };
}
