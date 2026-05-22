_: {
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      hyprlandWorkspaceNumbers
      mkNixhyprBindGroup
      # keep-sorted end
      ;
  in {
    config.programs.nixhypr.bindGroups = [
      (mkNixhyprBindGroup "Workspaces" (map (workspace: {
          description = "Workspace ${toString workspace}";

          keys = ["SUPER" (toString workspace)];
          lua = "hyprsplit.dsp.focus({ workspace = ${toString workspace} })";
        })
        hyprlandWorkspaceNumbers))

      (mkNixhyprBindGroup "Move To Workspace" (map (workspace: {
          description = "Move to workspace ${toString workspace}";

          keys = ["SUPER" "SHIFT" (toString workspace)];
          lua = "hyprsplit.dsp.window.move({ workspace = ${toString workspace} })";
        })
        hyprlandWorkspaceNumbers))

      (mkNixhyprBindGroup "Move To Workspace Silent" (map (workspace: {
          description = "Move to workspace ${toString workspace} (silent)";

          keys = ["SUPER" "CTRL" (toString workspace)];
          lua = "hyprsplit.dsp.window.move({ workspace = ${toString workspace}, follow = false })";
        })
        hyprlandWorkspaceNumbers))
    ];
  };
}
