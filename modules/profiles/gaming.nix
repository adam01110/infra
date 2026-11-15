{
  flake.aspects = {aspects, ...}: {
    gaming.includes = with aspects; [
      # keep-sorted start
      heroic
      lsfg
      mangohud
      mcpelauncher
      optiscaler
      prism
      sober
      steam
      # keep-sorted end
    ];
  };
}
