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
      concatMapAttrs
      isAttrs
      # keep-sorted end
      ;
    inherit (pkgs) fetchurl;
    inherit (pkgs.stdenvNoCC) mkDerivation;

    flattenSettings = prefix:
      concatMapAttrs (name: value: let
        key =
          if prefix == ""
          then name
          else "${prefix}.${name}";
      in
        if isAttrs value
        then flattenSettings key value
        else {${key} = value;});

    piQol = mkDerivation {
      pname = "pi-qol";
      version = "1.7.3";

      src = fetchurl {
        url = "https://registry.npmjs.org/@vanillagreen/pi-qol/-/pi-qol-1.7.3.tgz";
        hash = "sha256-6RMLDVk68LGQitELBcvDVAwUNob9eYyy+h8sdPjli+s=";
      };

      postPatch = ''
        substituteInPlace extensions/qol.ts \
          --replace-fail \
            $'\tpi.on("message_update", (event, ctx) => {\n\t\tif (ctx.hasUI) requestRender();\n\t\tif (!updateThinkingTimerEnabled(ctx)) return;' \
            $'\tpi.on("message_update", (event, ctx) => {\n\t\tif (!updateThinkingTimerEnabled(ctx)) return;'
      '';

      installPhase = ''
        runHook preInstall
        cp -r . "$out"
        runHook postInstall
      '';
    };
  in {
    programs.pi.coding-agent = {
      extensions = ["${piQol}/extensions/qol.ts"];

      settings.vstack.extensionManager.config."@vanillagreen/pi-qol" = flattenSettings "" {
        # keep-sorted start
        compactPrompt = false;
        enableHandoffCommand = false;
        enableScheduleCommand = false;
        replaceFooter = false;
        # keep-sorted end

        notification = {
          # keep-sorted start
          bell = false;
          muteBellSound = true;
          # keep-sorted end
        };

        sessionAutoRename.model = "openai-codex/gpt-5.6-luna";
        statusline.enabled = false;
        thinkingTimer.enabled = false;
        workingIndicator.mode = "static";
      };
    };
  };
}
