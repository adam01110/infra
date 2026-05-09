{
  flake.modules.homeManager.opencode = {
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
  in {
    programs.opencode.settings.formatter = {
      # keep-sorted start block=yes newline_separated=yes
      alejandra = {
        command = [(getExe pkgs.alejandra) "$FILE"];
        extensions = [".nix"];
      };

      fish_indent = {
        command = [
          (getExe' pkgs.fish "fish_indent")
          "--write"
          "$FILE"
        ];
        extensions = [".fish"];
      };

      ktlint = {
        command = [
          (getExe pkgs.ktlint)
          "-F"
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".kt"
          ".kts"
          # keep-sorted end
        ];
      };

      oxfmt = {
        command = [
          (getExe pkgs.oxfmt)
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".cjs"
          ".css"
          ".hbs"
          ".html"
          ".js"
          ".json"
          ".json5"
          ".jsonc"
          ".jsx"
          ".less"
          ".mjs"
          ".scss"
          ".toml"
          ".ts"
          ".tsx"
          ".yaml"
          ".yml"
          # keep-sorted end
        ];
      };

      oxlint = {
        command = [
          (getExe pkgs.oxlint)
          "--fix"
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".cjs"
          ".js"
          ".jsx"
          ".mjs"
          ".ts"
          ".tsx"
          # keep-sorted end
        ];
      };

      ruff = {
        command = [
          (getExe pkgs.ruff)
          "format"
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".py"
          ".pyi"
          # keep-sorted end
        ];
      };

      rustfmt = {
        command = [(getExe pkgs.rustfmt) "$FILE"];
        extensions = [".rs"];
      };

      shfmt = {
        command = [
          (getExe pkgs.shfmt)
          "--write"
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".bash"
          ".sh"
          # keep-sorted end
        ];
      };

      stylua = {
        command = [
          (getExe pkgs.stylua)
          "--respect-ignores"
          "$FILE"
        ];
        extensions = [".lua"];
      };

      rumdl = {
        command = [
          (getExe pkgs.rumdl)
          "fmt"
          "--fix"
          "$FILE"
        ];
        extensions = [
          # keep-sorted start
          ".markdown"
          ".md"
          # keep-sorted end
        ];
      };

      selene = {
        command = [
          (getExe pkgs.selene)
          "--display-style"
          "quiet"
          "$FILE"
        ];
        extensions = [".lua"];
      };
      # keep-sorted end
    };
  };
}
