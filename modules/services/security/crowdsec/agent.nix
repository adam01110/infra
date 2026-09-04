{
  flake.modules.nixos.crowdsec-agent = {self, ...}: {
    imports = [self.modules.nixos.crowdsec-base];

    services.crowdsec.settings.config.api.server.enable = false;
  };
}
