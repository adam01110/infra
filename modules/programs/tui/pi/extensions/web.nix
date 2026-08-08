{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      buildNpmPackage
      fetchFromGitHub
      jq
      runCommand
      # keep-sorted end
      ;

    jsonFormat = pkgs.formats.json {};

    webAccessSource = runCommand "pi-web-access-source-0.19.0" {nativeBuildInputs = [jq];} ''
      cp -r ${fetchFromGitHub {
        owner = "nicobailon";
        repo = "pi-web-access";
        tag = "v0.19.0";
        hash = "sha256-tLk/n0a5ZBa00CKe6DnfhiedPOBqOp99MT5Qg5sKTRc=";
      }}/. "$out"
      chmod -R u+w "$out"

      jq '.packages |= with_entries(select(.key == "" or ((.value.peer // false) | not)))' \
        "$out/package-lock.json" >package-lock.json
      mv package-lock.json "$out/package-lock.json"
    '';

    webAccess = buildNpmPackage {
      pname = "pi-web-access";
      version = "0.19.0";

      src = webAccessSource;

      npmDepsHash = "sha256-8cS65snxHQM5r4dXyv9ntTAYgLh1MvuFQrK8paIOqlI=";
      npmInstallFlags = [
        "--legacy-peer-deps"
        "--omit=dev"
      ];

      dontNpmBuild = true;

      postPatch = ''
        substituteInPlace index.ts \
          --replace-fail \
            $'if (initConfig.webSearch?.enabled !== false) pi.registerTool({\n\t\tname: toolNames.webSearch,' \
            $'if (initConfig.webSearch?.enabled !== false) pi.registerTool({\n\t\trenderShell: "self",\n\t\tname: toolNames.webSearch,' \
          --replace-fail \
            $'\tpi.registerTool({\n\t\tname: toolNames.fetchContent,' \
            $'\tpi.registerTool({\n\t\trenderShell: "self",\n\t\tname: toolNames.fetchContent,' \
          --replace-fail \
            $'\tpi.registerTool({\n\t\tname: toolNames.getSearchContent,' \
            $'\tpi.registerTool({\n\t\trenderShell: "self",\n\t\tname: toolNames.getSearchContent,' \
          --replace-fail \
            $'export default function (pi: ExtensionAPI) {\n\tconst initConfig' \
            $'export default function (pi: ExtensionAPI) {\n\tconst renderStatus = (label: string, content: unknown, theme: any, color: "error" | "success") => {\n\t\tconst text = typeof content === "string" ? content : "";\n\t\treturn new Text(theme.fg(color, "● ") + theme.fg("text", theme.bold(label + " ")) + theme.fg("muted", text), 0, 0);\n\t};\n\tpi.registerMessageRenderer("web-search-content-ready", (message, _options, theme) =>\n\t\trenderStatus("Web Search", message.content, theme, "success"));\n\tpi.registerMessageRenderer("web-search-error", (message, _options, theme) =>\n\t\trenderStatus("Web Search", message.content, theme, "error"));\n\n\tconst initConfig'
      '';

      installPhase = ''
        runHook preInstall
        cp -r . "$out"
        runHook postInstall
      '';
    };
  in {
    programs.pi.coding-agent.extensions = ["${webAccess}/index.ts"];

    home.file.".pi/web-search.json".source = jsonFormat.generate "web-search.json" {
      summaryModel = "openai-codex/gpt-5.6-luna";

      githubClone.enabled = true;
      video.enabled = false;
      youtube.enabled = false;
    };
  };
}
