{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    inherit (pkgs) writeText;

    cacheStatusColor = writeText "cache-status-color.ts" ''
      import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

      export default function (pi: ExtensionAPI): void {
        let restoreStatus: (() => void) | undefined;

        pi.on("session_start", (_event, ctx) => {
          if (!ctx.hasUI) return;

          const ui = ctx.ui;
          const setStatus = ui.setStatus;
          const styledSetStatus = (key: string, text: string | undefined): void =>
            setStatus.call(
              ui,
              key,
              key === "pi-cache-stats" && text
                ? ui.theme.fg("dim", text)
                : text,
            );

          ui.setStatus = styledSetStatus;
          restoreStatus = () => {
            if (ui.setStatus === styledSetStatus) ui.setStatus = setStatus;
          };
        });

        pi.on("session_shutdown", () => restoreStatus?.());
      }
    '';
  in {
    programs.pi.coding-agent.extensions = [
      cacheStatusColor
      "npm:pi-cache-optimizer@2.6.17"
    ];
  };
}
