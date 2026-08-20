{
  flake.modules.homeManager.pi = {
    programs.pi.coding-agent.settings.vstack.extensionManager.config."@vanillagreen/pi-tool-renderer" = {
      # keep-sorted start
      compactUserMessages = false;
      pendingStatusAnimation = true;
      renderBashDiffs = true;
      renderGitDiffCommandDiffs = true;
      renderGrepFindTools = false;
      renderMutationTools = true;
      # keep-sorted end
    };
  };
}
