{inputs, ...}: {
  flake-file.inputs = {
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkOrder;
  in {
    wayland.windowManager.hyprland.plugins = [pkgs.hyprlandPlugins.hyprfocus];

    programs.hylix = {
      _generatedConfig = mkOrder 899 ''
        -- Expose hyprsplit for keybind dispatchers.
        hyprsplit = dofile("${pkgs.nur.repos.adam0.hyprsplit}/init.lua")
        hyprsplit.config({ num_workspaces = 8 })
      '';

      settings.plugin.hyprfocus = {
        # keep-sorted start
        bounce_strength = 0.995;
        mode = "bounce";
        # keep-sorted end
      };
    };
  };

  flake.overlays.hyprland-plugins = final: prev: let
    hyprfocusPatch = final.writeText "hyprfocus-drop-hash-check.patch" ''
      diff --git a/main.cpp b/main.cpp
      index 900ff33..dc76942 100644
      --- a/main.cpp
      +++ b/main.cpp
      @@ -143,15 +143,6 @@ APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
       APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
           PHANDLE = handle;

      -    const std::string HASH        = __hyprland_api_get_hash();
      -    const std::string CLIENT_HASH = __hyprland_api_get_client_hash();
      -
      -    if (HASH != CLIENT_HASH) {
      -        HyprlandAPI::addNotification(PHANDLE, "[hyprwinwrap] Failure in initialization: Version mismatch (headers ver is not equal to running hyprland ver)",
      -                                     CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
      -        throw std::runtime_error("[hww] Version mismatch");
      -    }
      -
           static auto P = Event::bus()->m_events.window.active.listen([&](PHLWINDOW w, Desktop::eFocusReason r) { onFocusChange(w, r); });

           configValues.enable = makeShared<Config::Values::CBoolValue>("plugin:hyprfocus:enable", "enable or disable the plugin", true);
    '';
    upstream = inputs.hyprland-plugins.overlays.default final prev;
  in
    upstream
    // {
      hyprlandPlugins =
        upstream.hyprlandPlugins
        // {
          hyprfocus = upstream.hyprlandPlugins.hyprfocus.overrideAttrs (old: {
            patches = (old.patches or []) ++ [hyprfocusPatch];
          });
        };
    };
}
