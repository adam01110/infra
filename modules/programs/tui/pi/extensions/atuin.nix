{
  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkOrder;
    inherit (pkgs) fetchurl;
    inherit (pkgs.stdenvNoCC) mkDerivation;

    piAtuin = mkDerivation {
      pname = "pi-atuin";
      version = "0.1.9";

      src = fetchurl {
        url = "https://registry.npmjs.org/pi-atuin/-/pi-atuin-0.1.9.tgz";
        hash = "sha256-bVo83sni1EM5TEmfH0VLkjmBqD80TQ76MB/VzQEM+II=";
      };

      postPatch = ''
        substituteInPlace index.ts \
          --replace-fail \
            $'\t\tctx.ui.setEditorComponent((tui, theme, keybindings) => {\n\t\t\tconst editor = new CustomEditor(tui, theme, keybindings);' \
            $'\t\tconst previousEditor = ctx.ui.getEditorComponent();\n\t\tctx.ui.setEditorComponent((tui, theme, keybindings) => {\n\t\t\tconst editor = (previousEditor?.(tui, theme, keybindings) ?? new CustomEditor(tui, theme, keybindings)) as CustomEditor;\n\t\t\tconst previousShortcut = editor.onExtensionShortcut;' \
          --replace-fail \
            $'\t\t\t\treturn false;\n\t\t\t};' \
            $'\t\t\t\treturn previousShortcut?.(data) ?? false;\n\t\t\t};'
      '';

      installPhase = ''
        runHook preInstall
        cp -r . "$out"
        runHook postInstall
      '';
    };
  in {
    # Layer history search over QOL's editor instead of replacing it.
    programs.pi.coding-agent.extensions = mkOrder 1250 ["${piAtuin}/index.ts"];
  };
}
