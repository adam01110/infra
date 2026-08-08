{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    inherit (pkgs) writeText;

    jsonFormat = pkgs.formats.json {};

    autoformatRenderer = writeText "pi-autoformat-renderer.ts" ''
      import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
      import { Text } from "@earendil-works/pi-tui";

      export default function (pi: ExtensionAPI): void {
        pi.registerMessageRenderer("autoformat-steering", (message, { expanded }, theme) => {
          const content = message.content.replace(/^\[pi-autoformat\]\s*/, "");
          const formatted = content.match(/^Formatted (\d+) file\(s\):\s*([^\n]+)/);
          const failed = content.includes("Failures:");
          const count = formatted?.[1];
          const label = count === "1" ? "file" : "files";
          const status = failed
            ? theme.fg("warning", "formatter failures")
            : theme.fg("success", `formatted ''${count ?? "0"} ''${label}`);
          const hint = expanded ? "" : theme.fg("dim", " · ctrl+o to expand");
          let text = theme.fg("accent", "● ") + theme.fg("text", theme.bold("Autoformat "));
          text += theme.fg("dim", "· ") + status + hint;

          if (expanded) {
            const trailing = formatted ? content.slice(formatted[0].length).trim() : content;
            const lines = [
              ...(formatted?.[2].split(/,\s*/) ?? []),
              ...trailing.split("\n"),
            ].filter(Boolean);
            for (const [index, line] of lines.entries()) {
              const connector = index === lines.length - 1 ? "└─ " : "├─ ";
              text += `\n''${theme.fg("muted", connector)}''${theme.fg(failed ? "warning" : "dim", line)}`;
            }
          }

          return new Text(text, 0, 0);
        });
      }
    '';
  in {
    programs.pi.coding-agent.extensions = [
      "npm:@gotgenes/pi-autoformat@5.1.8"
      autoformatRenderer
    ];

    home.file.".pi/agent/extensions/pi-autoformat/config.json".source = jsonFormat.generate "pi-autoformat.json" {
      formatterOutput.onFailure = "both";
      hideSummariesInTui = true;

      formatters = {
        # keep-sorted start block=yes newline_separated=yes
        alejandra.command = [(getExe pkgs.alejandra)];

        fish_indent.command = [
          (getExe' pkgs.fish "fish_indent")
          "--write"
        ];

        ktlint.command = [
          (getExe pkgs.ktlint)
          "-F"
        ];

        oxfmt.command = [(getExe pkgs.oxfmt)];

        oxlint.command = [
          (getExe pkgs.oxlint)
          "--fix"
        ];

        ruff.command = [
          (getExe pkgs.ruff)
          "format"
        ];

        rumdl.command = [
          (getExe pkgs.rumdl)
          "fmt"
        ];

        rustfmt.command = [(getExe pkgs.rustfmt)];

        selene.command = [
          (getExe pkgs.selene)
          "--display-style"
          "quiet"
        ];

        shfmt.command = [
          (getExe pkgs.shfmt)
          "--write"
        ];

        stylua.command = [
          (getExe pkgs.stylua)
          "--respect-ignores"
        ];
        # keep-sorted end
      };

      chains = {
        # keep-sorted start
        ".bash" = ["shfmt"];
        ".cjs" = ["oxfmt" "oxlint"];
        ".css" = ["oxfmt"];
        ".fish" = ["fish_indent"];
        ".hbs" = ["oxfmt"];
        ".html" = ["oxfmt"];
        ".js" = ["oxfmt" "oxlint"];
        ".json" = ["oxfmt"];
        ".json5" = ["oxfmt"];
        ".jsonc" = ["oxfmt"];
        ".jsx" = ["oxfmt" "oxlint"];
        ".kt" = ["ktlint"];
        ".kts" = ["ktlint"];
        ".less" = ["oxfmt"];
        ".lua" = ["stylua" "selene"];
        ".markdown" = ["rumdl"];
        ".md" = ["rumdl"];
        ".mjs" = ["oxfmt" "oxlint"];
        ".nix" = ["alejandra"];
        ".py" = ["ruff"];
        ".pyi" = ["ruff"];
        ".rs" = ["rustfmt"];
        ".scss" = ["oxfmt"];
        ".sh" = ["shfmt"];
        ".toml" = ["oxfmt"];
        ".ts" = ["oxfmt" "oxlint"];
        ".tsx" = ["oxfmt" "oxlint"];
        ".yaml" = ["oxfmt"];
        ".yml" = ["oxfmt"];
        # keep-sorted end
      };
    };
  };
}
