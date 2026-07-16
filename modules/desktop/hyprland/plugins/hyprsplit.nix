{
  flake.modules.homeManager.hyprlandHyprsplitPlugin = {
    lib,
    pkgs,
    ...
  }: {
    programs.hylix._generatedConfig = lib.mkOrder 899 ''
      -- Expose hyprsplit for keybind dispatchers.
      hyprsplit = dofile("${pkgs.nur.repos.adam0.hyprsplit}/init.lua")
      hyprsplit.config({ num_workspaces = 8 })
    '';
  };
}
