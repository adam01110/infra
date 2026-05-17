{self, ...}: {
  flake.modules.homeManager.face = {
    # Copy user avatar for display managers.
    home.file.".face".source = "${self}/assets/face.png";
  };
}
