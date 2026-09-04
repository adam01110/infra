{
  flake.modules = {
    nixos.seahorse.programs.seahorse.enable = true;

    homeManager.seahorse.dconf.settings."apps/seahorse/listing".item-filter = "any";
  };
}
