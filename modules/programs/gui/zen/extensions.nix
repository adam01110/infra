{
  flake.modules.homeManager.zen = {pkgs, ...}: let
    inherit (builtins) mapAttrs;
  in {
    # Add extensions packaged in NUR.
    programs.zen-browser.profiles.default.extensions = {
      force = true;
      packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # Content blocking.
        # keep-sorted start
        consent-o-matic
        don-t-fuck-with-paste
        fastforwardteam
        istilldontcareaboutcookies
        localcdn
        sponsorblock
        ublock-origin
        # keep-sorted end

        # Annoyances.
        # keep-sorted start
        bitwarden
        darkreader
        dearrow
        indie-wiki-buddy
        libredirect
        modrinthify
        pronoundb
        return-youtube-dislikes
        translate-web-pages
        violentmonkey
        wikiwand-wikipedia-modernized
        # keep-sorted end

        kagi-search
      ];
    };

    # Force-install extensions missing from NUR.
    programs.zen-browser.policies.ExtensionSettings = let
      mkExtensionSettings = mapAttrs (
        _: pluginId: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
          installation_mode = "force_installed";
        }
      );
    in
      (mkExtensionSettings {
        "{76ef94a4-e3d0-4c6f-961a-d38a429a332b}" = "ttv-lol-pro";
        "{microslop@4o4}" = "microslop";
        "@crw-extension-firefox" = "consumer-rights-wiki";
      })
      // {
        "magnolia@12.34" = {
          install_url = "https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-latest.xpi";
          installation_mode = "force_installed";
        };
      };
  };
}
