{
  flake.aspects.helium.homeManager = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      fromHexString
      genAttrs
      getExe
      getExe'
      mapAttrs
      toInt
      # keep-sorted end
      ;

    jsonFormat = pkgs.formats.json {};

    colors = config.lib.stylix.colors;

    profile = "${config.xdg.configHome}/net.imput.helium";

    # Signed ARGB, as Chromium stores SkColor prefs. Only the hue reaches the
    # surfaces the theme leaves to the color pipeline; base05's is the warmest
    # close match to base00.
    seed = fromHexString "ff${colors.base05}" - 4294967296;

    rgb = name: map (channel: toInt colors."${name}-rgb-${channel}") ["r" "g" "b"];

    # Paints the frame, tabs and toolbar; settings pages and menus still come
    # from the seeded palette.
    manifest = jsonFormat.generate "helium-stylix-theme.json" {
      manifest_version = 3;
      name = "Stylix";
      version = "1.0";
      theme.colors = mapAttrs (_: rgb) (
        genAttrs [
          "background_tab"
          "background_tab_inactive"
          "frame"
          "frame_inactive"
          "frame_incognito"
          "frame_incognito_inactive"
          "ntp_background"
          "toolbar"
        ] (_: "base00")
        // genAttrs [
          "bookmark_text"
          "ntp_text"
          "omnibox_text"
          "tab_text"
          "toolbar_button_icon"
          "toolbar_text"
        ] (_: "base05")
        // {
          ntp_header = "base01";
          ntp_link = "base0D";
          omnibox_background = "base01";
          tab_background_text = "base04";
          tab_background_text_inactive = "base04";
        }
      );
    };
  in {
    # Helium only reads an unpacked theme when it is installed, and installing
    # clears the seed, so a changed theme is loaded on one launch and the seed
    # returns on the next. Helium rewrites Preferences on exit, so a running
    # browser is left alone.
    programs.helium.prelaunch = ''
      if ! ${getExe' pkgs.procps "pgrep"} -x helium >/dev/null; then
        theme=${profile}/stylix-theme
        prefs=${profile}/Default/Preferences
        mkdir -p "$theme"
        if ! ${getExe' pkgs.diffutils "cmp"} -s ${manifest} "$theme/manifest.json"; then
          install -m 644 ${manifest} "$theme/manifest.json"
          rm -f "$theme/Cached Theme.pak"
        fi
        if [ ! -f "$theme/Cached Theme.pak" ]; then
          set -- --load-extension="$theme" "$@"
        elif [ -f "$prefs" ]; then
          tmp=$(mktemp)
          ${getExe pkgs.jq} --argjson seed ${toString seed} \
            '.browser.theme += {user_color2: $seed, color_variant2: 2, is_grayscale2: false}' \
            "$prefs" >"$tmp" && mv "$tmp" "$prefs"
        fi
      fi
    '';
  };
}
