{
  flake.aspects.albedo.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
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

        astyle.command = [
          (getExe pkgs.astyle)
          "--suffix=none"
        ];

        biome.command = [
          (getExe pkgs.biome)
          "format"
          "--write"
        ];

        dockerfmt.command = [
          (getExe pkgs.dockerfmt)
          "--write"
        ];

        fish_indent.command = [
          (getExe' pkgs.fish "fish_indent")
          "--write"
        ];

        jsonfmt.command = [
          (getExe pkgs.jsonfmt)
          "--write"
        ];

        ktlint.command = [
          (getExe pkgs.ktlint)
          "-F"
        ];

        mago.command = [
          (getExe pkgs.mago)
          "format"
        ];

        prettier.command = [
          (getExe pkgs.prettier)
          "--write"
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

        shfmt.command = [
          (getExe pkgs.shfmt)
          "--write"
        ];

        stylua.command = [
          (getExe pkgs.stylua)
          "--respect-ignores"
        ];

        tombi.command = [
          (getExe pkgs.tombi)
          "format"
        ];
        # keep-sorted end
      };

      chains = {
        # keep-sorted start
        ".bash" = ["shfmt"];
        ".cjs" = ["biome"];
        ".css" = ["biome"];
        ".dockerfile" = ["dockerfmt"];
        ".fish" = ["fish_indent"];
        ".java" = ["astyle"];
        ".js" = ["biome"];
        ".json" = ["jsonfmt"];
        ".jsonc" = ["jsonfmt"];
        ".kt" = ["ktlint"];
        ".kts" = ["ktlint"];
        ".lua" = ["stylua"];
        ".markdown" = ["rumdl"];
        ".md" = ["rumdl"];
        ".mjs" = ["biome"];
        ".nix" = ["alejandra"];
        ".php" = ["mago"];
        ".py" = ["ruff"];
        ".pyi" = ["ruff"];
        ".rs" = ["rustfmt"];
        ".sh" = ["shfmt"];
        ".toml" = ["tombi"];
        ".ts" = ["biome"];
        ".yaml" = ["prettier"];
        ".yml" = ["prettier"];
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
