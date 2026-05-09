{
  flake.modules.homeManager.opencode = {lib, ...}: let
    inherit
      (builtins)
      # keep-sorted start
      attrNames
      foldl'
      readDir
      # keep-sorted end
      ;
    inherit
      (lib)
      # keep-sorted start
      filterAttrs
      hasSuffix
      mapAttrs'
      nameValuePair
      removeSuffix
      # keep-sorted end
      ;

    mkSkills = prefix: dir:
      mapAttrs' (
        name: _:
          nameValuePair "${prefix}${removeSuffix ".md" name}" {
            source = dir + "/${name}";
          }
      ) (filterAttrs (name: type: type == "regular" && hasSuffix ".md" name) (readDir dir));

    rootEntries = readDir ./.;
    skillDirectories = attrNames (filterAttrs (_: type: type == "directory") rootEntries);
    rootSkills = mkSkills "" ./.;
    prefixedSkills = foldl' (acc: dir: acc // mkSkills "${dir}-" (./. + "/${dir}")) {} skillDirectories;
  in {
    home.file = mapAttrs' (
      name: value: nameValuePair ".agents/skills/${name}/SKILL.md" value
    ) (rootSkills // prefixedSkills);
  };
}
