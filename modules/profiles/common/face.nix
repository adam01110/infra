{self, ...}: {
  flake.aspects.face.homeManager.home.file.".face".source = "${self}/assets/face.png";
}
