{
  flake.aspects.pdfcraft.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.pdfcraft];
  };
}
