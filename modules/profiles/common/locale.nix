{self, ...}: {
  flake.modules.nixos.locale = {vars, ...}: let
    inherit
      (vars)
      # keep-sorted start
      defaultLocale
      regionalLocale
      # keep-sorted end
      ;
  in {
    imports = [self.modules.generic.vars];

    i18n = {
      inherit defaultLocale;
      extraLocaleSettings = {
        # keep-sorted start
        LC_ADDRESS = regionalLocale;
        LC_COLLATE = defaultLocale;
        LC_CTYPE = defaultLocale;
        LC_MEASUREMENT = regionalLocale;
        LC_MESSAGES = defaultLocale;
        LC_MONETARY = regionalLocale;
        LC_NAME = regionalLocale;
        LC_NUMERIC = regionalLocale;
        LC_PAPER = regionalLocale;
        LC_TELEPHONE = regionalLocale;
        LC_TIME = defaultLocale;
        # keep-sorted end
      };
    };
  };
}
