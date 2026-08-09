{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkAfter;
    inherit (pkgs) fetchurl;
    inherit (pkgs.stdenvNoCC) mkDerivation;

    toolRenderer = mkDerivation {
      pname = "pi-tool-renderer";
      version = "1.7.1";

      src = fetchurl {
        url = "https://registry.npmjs.org/@vanillagreen/pi-tool-renderer/-/pi-tool-renderer-1.7.1.tgz";
        hash = "sha256-hmss/FFMOiBomeq8B5gxQIw1GwXUUVIuwEiAZdj8co8=";
      };

      postPatch = ''
        substituteInPlace extensions/tool-renderer.ts \
          --replace-fail \
            $'\tregisterReadOnly(pi, agent, cwd, "grep");\n\tregisterReadOnly(pi, agent, cwd, "find");' \
            $'\tif (settingBoolean("renderGrepFindTools", true, cwd)) {\n\t\tregisterReadOnly(pi, agent, cwd, "grep");\n\t\tregisterReadOnly(pi, agent, cwd, "find");\n\t}'

        substituteInPlace extensions/tool-renderer/generic.ts \
          --replace-fail \
            $'\ttextContent,\n\ttype TruncatedLines,' \
            $'\ttextContent,\n\trenderToolPathText,\n\ttype TruncatedLines,' \
          --replace-fail \
            $'\t"get_search_content",\n\t"code_search",' \
            $'\t"get_search_content",\n\t"lsp_definition",\n\t"lsp_diagnostics",\n\t"lsp_hover",\n\t"lsp_references",\n\t"lsp_symbols",\n\t"code_search",' \
          --replace-fail \
            $'export function renderGenericToolCall(name: string, args: any, theme: any, context: any): TruncatedLines {\n\treturn makeTruncatedLines(`''${genericStatusPrefix(context, theme)}''${toolLabel(theme, `''${humanizeToolName(name)} `)}''${summarizeGenericCall(name, args, theme)}`);\n}' \
            $'export function renderGenericToolCall(name: string, args: any, theme: any, context: any): TruncatedLines {\n\tif (name === "lsp_diagnostics") {\n\t\treturn makeTruncatedLines(`''${genericStatusPrefix(context, theme)}''${toolLabel(theme, "LSP Diagnostics ")}''${renderToolPathText(args?.path, theme, context?.cwd)}`);\n\t}\n\treturn makeTruncatedLines(`''${genericStatusPrefix(context, theme)}''${toolLabel(theme, `''${humanizeToolName(name)} `)}''${summarizeGenericCall(name, args, theme)}`);\n}' \
          --replace-fail \
            $'export function renderGenericToolResult(name: string, result: any, { expanded, isPartial }: any, theme: any, context: any): TruncatedLines | ReturnType<typeof makeEmpty> {\n\tif (isPartial) return renderPendingDetail(`''${humanizeToolName(name)}…`, theme);\n\tclearBlink(context);\n\tconst raw = textContent(result).trim();' \
            $'export function renderGenericToolResult(name: string, result: any, { expanded, isPartial }: any, theme: any, context: any): TruncatedLines | ReturnType<typeof makeEmpty> {\n\tif (isPartial) return renderPendingDetail(`''${humanizeToolName(name)}…`, theme);\n\tclearBlink(context);\n\tconst raw = textContent(result).trim();\n\tif (name === "lsp_diagnostics") {\n\t\tconst lines = raw ? splitTerminalLines(raw) : [];\n\t\tif (context?.isError) {\n\t\t\treturn makeTruncatedLines(`''${treeConnector(theme, "└")}''${theme.fg("error", lines[0] || "LSP diagnostics failed")}`);\n\t\t}\n\t\tif (lines.length === 0) return makeTruncatedLines(`''${treeConnector(theme, "└")}''${theme.fg("muted", "no diagnostics")}`);\n\t\treturn makeTruncatedLines(lines.map((line, index) => {\n\t\t\tconst color = line.includes(" - error:") ? "error" : line.startsWith("⚠️") || line.includes(" - warning:") ? "warning" : line.startsWith("✅") ? "success" : "dim";\n\t\t\treturn `''${treeConnector(theme, index === lines.length - 1 ? "└" : "│")}''${theme.fg(color, clipLine(line, context?.cwd))}`;\n\t\t}).join("\\n"));\n\t}'
      '';

      installPhase = ''
        runHook preInstall
        cp -r . "$out"
        runHook postInstall
      '';
    };
  in {
    programs.pi.coding-agent = {
      # Load after QOL so its tool renderers take precedence.
      extensions = mkAfter ["${toolRenderer}/extensions/tool-renderer.ts"];

      settings.vstack.extensionManager.config."@vanillagreen/pi-tool-renderer" = {
        # keep-sorted start
        compactUserMessages = false;
        pendingStatusAnimation = true;
        renderBashDiffs = true;
        renderGitDiffCommandDiffs = true;
        renderGrepFindTools = false;
        renderMutationTools = true;
        # keep-sorted end
      };
    };
  };
}
