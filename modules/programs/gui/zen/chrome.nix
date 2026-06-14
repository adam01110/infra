{
  flake-file.inputs = {
    nix-userstyles = {
      url = "github:adam01110/nix-userstyles";
      inputs = {
        # keep-sorted start
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
  };

  flake.modules.homeManager.zen = {
    # keep-sorted start
    config,
    inputs,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit (lib) mkAfter;
    inherit (lib.self) stylixPalette;

    inherit (pkgs.stdenv.hostPlatform) system;

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
            "google"
            "google-drive"
            "hacker-news"
            "home-manager-options-search"
            "indie-wiki-buddy"
            "lastfm"
            "linkedin"
            "lobste.rs"
            "mastodon"
            "mdbook"
            "mdn"
            "modrinth"
            "namemc"
            "neovim.io"
            "nitter"
            "nixos-manual"
            "nixos-search"
            "npm"
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
            "twitch"
            "web.dev"
            "wiki.nixos.org"
            "wikipedia"
            "wikiwand"
            "youtube"
            "zen-browser-docs"
            # keep-sorted end

            {
              name = "anonymous-overflow";
              sites = [''domain("anonymous-overflow.zezura.xyz")''];
            }
          ];

          # Remove rounded corners on sites and apply nix-userstyles themes.
          extraCss = ''
            *,
            *::before,
            *::after {
              border-radius: 0px !important;
            }
          '';
        })
      );
    };
  };
}
