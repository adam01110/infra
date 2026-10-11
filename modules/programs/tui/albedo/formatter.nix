{
  flake.modules.homeManager.albedo = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe getExe';

    formatterSettings = {
      nix = [(getExe pkgs.nix)];
      treefmt = [(getExe pkgs.treefmt)];
      timeoutMs = 45000;
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
  in {
    programs.albedo.formatter = {
      enable = true;
      settings = formatterSettings;
    };
  };
}
