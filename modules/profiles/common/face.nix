{self, ...}: {
  flake.modules.homeManager.face = {
    home.file.".face".source = "${self}/assets/face.png";
  };
}
