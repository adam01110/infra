{
  inputs,
  self,
  ...
}: {
  flake.modules.homeManager.spotify = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.lib.stylix) colors;
    inherit (pkgs.stdenv.hostPlatform) system;

    font = config.stylix.fonts.monospace.name;
    spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  in {
    imports = [self.modules.homeManager.stylixPersonal];

    # keep-sorted start block=yes newline_separated=yes
    # Apply local Spicetify overrides on top of the Stylix palette.
    programs.spicetify = {
      theme = {
        name = "stylix";
        inherit (spicePkgs.themes.text) src;
        sidebarConfig = false;

        # Set font to stylix font.
        # Force the text theme to show all images.
        # Disable border highlight animations and fades.
        # Remove rounded corners from all elements for consistent styling.
        # Remove the ugly spotify-tui header.
        additionalCss = ''
          :root {
            --font-family: '${font}', monospace;

            --display-card-image: block;
            --display-coverart-image: block;
            --display-header-image: block;
            --display-sidebar-image: block;
            --display-tracklist-image: block;
            --border-transition: 0s;
          }

          .Root__globalNav,
          .main-yourLibraryX-entryPoints,
          .Root__main-view,
          .main-nowPlayingBar-container,
          .Root__right-sidebar:has(aside:not(:empty)) {
            transition: none !important;
          }

          .Root__globalNav::before,
          .Root__nav-bar .main-yourLibraryX-entryPoints::before,
          .Root__main-view::before,
          .main-nowPlayingBar-container::before,
          .Root__right-sidebar:has(aside:not(:empty))::before {
            transition: none !important;
          }

          .player-controls__buttons,
          .main-nowPlayingBar-extraControls,
          .main-connectBar-connectBar {
            opacity: 1 !important;
            transition: none !important;
          }

          *,
          *::before,
          *::after {
            border-radius: 0px !important;
          }

          .view-homeShortcutsGrid-shortcuts::before {
            content: "" !important;
          }
        '';
      };

      colorScheme = "custom";
      customColorScheme = with colors; {
        # keep-sorted start
        button = base04;
        button-active = base04;
        button-disabled = base03;
        card = base03;
        equalizer = base0B;
        highlight = base02;
        highlight-elevated = base03;
        main = base00;
        main-elevated = base02;
        misc = base02;
        notification = base02;
        notification-error = base08;
        player = base04;
        selected-row = base04;
        shadow = base00;
        sidebar = base01;
        subtext = base05;
        tab-active = base02;
        text = base05;
        # keep-sorted end

        # keep-sorted start
        accent = base0B;
        accent-active = base0B;
        accent-inactive = base00;
        banner = base0B;
        border-active = base0D;
        border-inactive = base01;
        header = base03;
        # keep-sorted end
      };
    };

    stylix.targets.spicetify.enable = false;
    # keep-sorted end
  };
}
