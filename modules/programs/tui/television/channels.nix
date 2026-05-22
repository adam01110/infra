{
  flake.modules.homeManager.television = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: {
    programs.television.package = pkgs.television.withPackages (
      _:
      # Bundle tools that channel commands shell out to.
        (with pkgs; [
          # keep-sorted start
          gnused
          tlrc
          trash-cli
          # keep-sorted end
        ])
        # Reuse packages from home-manager modules to avoid duplicate package selections.
        ++ (map (program: config.programs.${program}.package) [
          # keep-sorted start
          "bat"
          "eza"
          "man"
          "zoxide"
          # keep-sorted end
        ])
    );
  };
}
