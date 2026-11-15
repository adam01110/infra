{
  flake.aspects.java.nixos = {
    programs.java = {
      enable = true;
      binfmt = true;
    };
  };
}
