{
  flake.aspects.bitwarden.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # keep-sorted start
      bitwarden-cli
      bitwarden-desktop
      # keep-sorted end
    ];
  };
}
