{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    jsonFormat = pkgs.formats.json {};
  in {
    home.file.".pi/web-search.json".source = jsonFormat.generate "web-search.json" {
      githubClone.enabled = true;
      video.enabled = false;
      youtube.enabled = false;
    };
  };
}
