{
  flake.modules.homeManager.pi = {lib, ...}: let
    inherit
      (lib)
      # keep-sorted start
      concatMapAttrs
      isAttrs
      # keep-sorted end
      ;

    # `settings` is a shallow attrs merge, so exactly one module may write
    # `settings.kendex`; a second writer would drop the other config block.
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
    programs.pi.coding-agent.settings.kendex.extensionManager.config = {
      # keep-sorted start block=yes newline_separated=yes
      "@vanillagreen/pi-qol" = flattenSettings "" {
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

        sessionAutoRename.model = "current";
        statusline.enabled = false;
        thinkingTimer.enabled = false;
        workingIndicator.mode = "static";
      };

      "@vanillagreen/pi-tool-renderer" = {
        # keep-sorted start
        pendingStatusAnimation = true;
        renderBashDiffs = true;
        renderGitDiffCommandDiffs = true;
        renderMutationTools = true;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
