{self, ...}: {
  flake.modules.homeManager.fzf = {lib, ...}: let
    inherit (lib) mkForce;
  in {
    imports = [self.modules.homeManager.stylixBase];

    programs.fzf = let
      enableShellIntegration = false;
    in {
      enable = true;

      colors.gutter = mkForce "-1";

      # keep-sorted start
      enableBashIntegration = enableShellIntegration;
      enableFishIntegration = enableShellIntegration;
      enableZshIntegration = enableShellIntegration;
      # keep-sorted end

      # Change prompt default to look better.
      defaultOptions = [
        # keep-sorted start
        "--border sharp"
        "--prompt '➜ '"
        # keep-sorted end
      ];
    };

    stylix.targets.fzf.colors.override.withHashtag = {
      base00 = "-1";
      base01 = "-1";
    };
  };
}
