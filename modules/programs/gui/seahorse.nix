{
  flake.aspects.seahorse = {
    nixos.programs.seahorse.enable = true;

    homeManager.dconf.settings."apps/seahorse/listing".item-filter = "any";
  };
}
