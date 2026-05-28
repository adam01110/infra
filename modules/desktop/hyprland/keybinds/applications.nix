{
  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    inherit (lib.self) mkNixhyprBindGroup;
  in {
    imports = with self.modules.homeManager; [
      # keep-sorted start
      discord
      ghostty
      zen
      # keep-sorted end
    ];

    config = let
      inherit (lib) getExe;

      # keep-sorted start
      ghostty = "${getExe config.programs.ghostty.package} --initial-window=false +new-window";
      runapp = getExe pkgs.runapp;
      # keep-sorted end

      app = command: "${runapp} ${command}";
    in {
      programs.nixhypr.bindGroups = [
        (mkNixhyprBindGroup "Applications" [
          # keep-sorted start block=yes newline_separated=yes
          {
            description = "Browser";

            keys = ["SUPER" "B"];
            exec = app (getExe config.programs.zen-browser.package);
          }

          {
            description = "Discord";

            keys = ["SUPER" "N"];
            exec = app (getExe config.programs.nixcord.equibop.package);
          }

          {
            description = "File manager";

            keys = ["SUPER" "E"];
            exec = app "${ghostty} -- ${getExe pkgs.yazi}";
          }

          {
            description = "Steam";

            keys = ["SUPER" "M"];
            exec = app "steam";
          }

          {
            description = "Terminal";

            keys = ["SUPER" "Return"];
            exec = app ghostty;
          }
          # keep-sorted end
        ])
      ];
    };
  };
}
