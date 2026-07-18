{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      buildNpmPackage
      fetchurl
      # keep-sorted end
      ;

    jsonFormat = pkgs.formats.json {};

    webAccess = buildNpmPackage {
      pname = "pi-web-access";
      version = "0.13.0";

      src = fetchurl {
        url = "https://registry.npmjs.org/pi-web-access/-/pi-web-access-0.13.0.tgz";
        hash = "sha256-GmPsueJdqj4Ny+fxlwMWRVnehe4bv1GeiBo0i5uAQAA=";
      };

      npmDepsHash = "sha256-8onTvv7nUrTXMGvwkMkPEYc+mtpxolzF6Z9EuuB9pbs=";
      npmInstallFlags = [
        "--legacy-peer-deps"
        "--omit=dev"
      ];

      dontNpmBuild = true;

      postPatch = ''
        cp ${./web/package-lock.json} package-lock.json

        substituteInPlace index.ts \
          --replace-fail \
            $'if (initConfig.webSearch?.enabled !== false) pi.registerTool({\n\t\tname: "web_search",' \
            $'if (initConfig.webSearch?.enabled !== false) pi.registerTool({\n\t\trenderShell: "self",\n\t\tname: "web_search",' \
          --replace-fail \
            $'\tpi.registerTool({\n\t\tname: "fetch_content",' \
            $'\tpi.registerTool({\n\t\trenderShell: "self",\n\t\tname: "fetch_content",' \
          --replace-fail \
            $'\tpi.registerTool({\n\t\tname: "get_search_content",' \
            $'\tpi.registerTool({\n\t\trenderShell: "self",\n\t\tname: "get_search_content",' \
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
