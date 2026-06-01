{self, ...}: {
  flake.modules.homeManager.hyprland = {lib, ...}: let
    inherit (lib) mkOrder;
  in {
    imports = with self.modules.homeManager; [
      # keep-sorted start block=yes
      {
        key = "homeManager-noctalia";
        imports = [noctalia];
      }
      {
        key = "homeManager-overzicht";
        imports = [overzicht];
      }
      # keep-sorted end
    ];

    config.programs.hylix = {
      _generatedConfig = mkOrder 899 ''
        local MAX_ZOOM = 3
        local MIN_ZOOM = 1
        local ZOOM_TOGGLE_FACTOR = 1.5

        local function zoom(factor)
            local current = hl.get_config("cursor.zoom_factor")
            if factor ~= nil then
                current = current * factor
            elseif current ~= MIN_ZOOM then
                current = MIN_ZOOM
            else
                current = ZOOM_TOGGLE_FACTOR
            end
            current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
            hl.config({ cursor = { zoom_factor = current } })
        end

        local function zoom_reset()
            hl.config({ cursor = { zoom_factor = MIN_ZOOM } })
        end
      '';

      settings.binds.movefocus_cycles_fullscreen = true;
    };
  };
}
