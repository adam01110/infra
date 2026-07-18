{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkAfter;

    toolRenderer = pkgs.stdenvNoCC.mkDerivation {
      pname = "pi-tool-renderer";
      version = "1.6.3";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@vanillagreen/pi-tool-renderer/-/pi-tool-renderer-1.6.3.tgz";
        hash = "sha256-WzZGoBZ9bh0F/gm/kh+F6UH+r2eGVbW01JVIwqAcfJo=";
      };

      postPatch = ''
        substituteInPlace extensions/tool-renderer.ts \
          --replace-fail \
            $'\tregisterReadOnly(pi, agent, cwd, "grep");\n\tregisterReadOnly(pi, agent, cwd, "find");' \
            $'\tif (settingBoolean("renderGrepFindTools", true, cwd)) {\n\t\tregisterReadOnly(pi, agent, cwd, "grep");\n\t\tregisterReadOnly(pi, agent, cwd, "find");\n\t}'

        substituteInPlace extensions/tool-renderer/generic.ts \
          --replace-fail \
            $'\t"get_search_content",\n\t"code_search",' \
            $'\t"get_search_content",\n\t"lsp_definition",\n\t"lsp_diagnostics",\n\t"lsp_hover",\n\t"lsp_references",\n\t"lsp_symbols",\n\t"code_search",'
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
        compactUserMessages = true;
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
