{
  flake.modules.homeManager.pi = {lib, ...}: let
    inherit
      (lib)
      # keep-sorted start
      concatMapAttrs
      isAttrs
      # keep-sorted end
      ;

    flattenSettings = prefix:
      concatMapAttrs (name: value: let
        key =
          if prefix == ""
          then name
          else "${prefix}.${name}";
      in
        if isAttrs value
        then flattenSettings key value
        else {${key} = value;});
  in {
    programs.pi.coding-agent.settings.kendex.extensionManager.config."@vanillagreen/pi-qol" = flattenSettings "" {
      # keep-sorted start
      compactPrompt = false;
      enableHandoffCommand = false;
      enableScheduleCommand = false;
      replaceFooter = false;
      # keep-sorted end

      notification = {
        # keep-sorted start
        bell = false;
        muteBellSound = true;
        # keep-sorted end
      };

      sessionAutoRename.model = "openai-codex/gpt-5.6-luna";
      statusline.enabled = false;
      thinkingTimer.enabled = false;
      workingIndicator.mode = "static";
    };
  };
}
