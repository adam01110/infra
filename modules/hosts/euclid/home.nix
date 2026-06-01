{
  flake.modules.nixos.euclid = {
    # keep-sorted start
    self,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    home-manager.users.${username} = {
      imports = with self.modules.homeManager; [
        # Profiles
        server
      ];

      # Gpu monitoring for intel integrated graphics.
      programs.nvtop.types = ["intel"];
    };
  };
}
