{
  flake-file.inputs.nix-userstyles = {
    url = "git+https://tangled.org/did:plc:zkwqzie5qsn4tqfkt4mvxqio";

    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      import-tree.follows = "import-tree";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      # keep-sorted end
    };
  };

  flake.modules.homeManager.zen = {
    # keep-sorted start
    config,
    inputs,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit (lib) mkAfter;
    inherit (lib.self) stylixPalette;
    inherit (pkgs.stdenv.hostPlatform) system;

    inherit (vars) groundDomain;

    # Convert the stylix base16 scheme into a format accepted by nix-userstyles.
    palette = stylixPalette config;
  in {
    # Remove rounded corners in Zen Browser interface.
    programs.zen-browser.profiles.default = {
      userChrome = ''
        *,
        *::before,
        *::after {
          border-radius: 0px !important;
        }
      '';

      # Append generated site styles after profile content overrides.
      userContent = mkAfter (
        readFile (inputs.nix-userstyles.lib.mkUserContent system {
          inherit palette;

          userStyles = [
            # keep-sorted start
            "advent-of-code"
            "alternativeto"
            "arch-wiki"
            "brave-search"
            "bsky"
            "bstats"
            "canvas-lms"
            "chatgpt"
            "codeberg"
            "crates.io"
            "dev.to"
            "devdocs"
            "discord"
            "docs.deno.com"
            "docs.rs"
            "freedesktop"
            "ghostty.org"
            "github"
            "gmail"
            "go.dev"
            "google"
            "google-drive"
            "google-gemini"
            "google-photos"
            "hacker-news"
            "have-i-been-pwned"
            "home-manager-options-search"
            "indie-wiki-buddy"
            "instagram"
            "lastfm"
            "libreddit"
            "linkedin"
            "lobste.rs"
            "mastodon"
            "mdbook"
            "mdn"
            "microsoft-word"
            "modrinth"
            "namemc"
            "neovim.io"
            "nitter"
            "nixos-manual"
            "nixos-search"
            "npm"
            "npmx"
            "planet-minecraft"
            "porkbun"
            "proton"
            "pypi"
            "react.dev"
            "reddit"
            "regex101"
            "rentry.co"
            "searchix"
            "shinigami-eyes"
            "spotify-web"
            "stack-overflow"
            "tangled"
            "twitch"
            "vercel"
            "web.dev"
            "wiki.nixos.org"
            "wikipedia"
            "wikiwand"
            "youtube"
            "zen-browser-docs"
            # keep-sorted end

            {
              name = "anonymous-overflow";
              sites = [''domain("anonymous-overflow.${groundDomain}")''];
            }
          ];

          # Apply global overrides alongside site themes.
          extraCss = ''
            *,
            *::before,
            *::after {
              border-radius: 0px !important;
              font-family: "${config.stylix.fonts.sansSerif.name}" !important;
              font-feature-settings: "calt" 1, "liga" 1, "dlig" 1 !important;
            }

            :is(pre, code, kbd, samp, tt),
            :is(pre, code, kbd, samp, tt) * {
              &,
              &::before,
              &::after {
                font-family: "${config.stylix.fonts.monospace.name}" !important;
              }
            }
          '';
        })
      );
    };
  };
}
