{
  flake.aspects.neovim.homeManager.programs.nvf.settings.vim.lsp = {
    presets.harper.enable = true;

    servers.harper = {
      # Supported filetypes missing from the preset, mirroring nvf PR #1867.
      # Merges with the preset list.
      filetypes = [
        # keep-sorted start
        "daml"
        "elixir"
        "gleam"
        "groovy"
        "ink"
        "jjdescription"
        "org"
        "plaintex"
        "ps1"
        "r"
        "scala"
        "sh"
        "solidity"
        "swift"
        "tex"
        "text"
        "toml"
        "typescript"
        "typescriptreact"
        "typst"
        "zig"
        # keep-sorted end
      ];

      settings.harper-ls = {
        dialect = "British";
        # Lint only English runs so occasional Dutch is not flagged.
        isolateEnglish = true;

        linters = {
          # Rules that are off by default.
          # keep-sorted start
          MissingIndefiniteArticle = true;
          MoreAdjective = true;
          NoOxfordComma = true;
          PossessiveNoun = true;
          ViciousCycle = true;
          # keep-sorted end

          # Defaults that contradict the rules above.
          OxfordComma = false;
        };
      };
    };
  };
}
