{inputs, ...}: {
  flake-file.inputs.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.spotify = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;

    # Access spicetify-nix packages.
    spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  in {
    imports = [inputs.spicetify-nix.homeManagerModules.spicetify];

    programs.spicetify = {
      enable = true;

      # Turn on experimental features, use wayland, and apply wm patch.
      # keep-sorted start
      experimentalFeatures = true;
      wayland = true;
      windowManagerPatch = true;
      # keep-sorted end

      # keep-sorted start block=yes newline_separated=yes
      # Enable extensions.
      enabledExtensions =
        # Extensions from spicetify-nix.
        (with spicePkgs.extensions; [
          # keep-sorted start
          aiBandBlocker
          betterGenres
          copyLyrics
          fullAlbumDate
          goToSong
          keyboardShortcut
          listPlaylistsWithSong
          playingSource
          queueTime
          sectionMarker
          seekSong
          wikify
          # keep-sorted end
        ])
        # Extensions from adam0's nur.
        ++ (with pkgs.nur.repos.adam0.spicetifyExtensions; [
          # keep-sorted start
          moreLyrics
          playlistIcons
          volumePercentage
          # keep-sorted end
        ]);

      # Enable CSS snippets.
      enabledSnippets = with spicePkgs.snippets; [
        # keep-sorted start
        pointer
        removeTheArtistsAndCreditsSectionsFromTheSidebar
        # keep-sorted end
      ];
      # keep-sorted end
    };
  };
}
