{
  flake.modules.nixos.printing = {pkgs, ...}: {
    services.printing = {
      enable = true;
      # Allow network clients to reach cups.
      openFirewall = true;

      webInterface = false;

      drivers = with pkgs; [
        # keep-sorted start
        foomatic-db-ppds
        foomatic-db-ppds-withNonfreeDb
        gutenprint
        gutenprint-bin
        splix
        # keep-sorted end
      ];

      # Enable network printer discovery and share local queues by default.
      browsing = true;
      defaultShared = true;
    };

    fonts.enableGhostscriptFonts = true;

    programs.system-config-printer.enable = true;
  };
}
