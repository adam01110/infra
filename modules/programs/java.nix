{
  flake.modules.nixos.java = {
    programs.java = {
      enable = true;
      binfmt = true;
    };
  };
}
