{
  flake.aspects.albedo.homeManager = _: {
    # Nerd Font Awesome glyphs; each must stay one terminal cell wide.
    programs.albedo.icons = {
      # keep-sorted start
      agentDone = "";
      archive = "";
      bookmark = "";
      branch = "";
      callFailed = "";
      callSucceeded = "";
      itemEditing = "";
      itemMoved = "";
      itemPinned = "";
      keyDown = "";
      keyLeft = "";
      keyRight = "";
      keyUp = "";
      prompt = "";
      # keep-sorted end
    };
  };
}
