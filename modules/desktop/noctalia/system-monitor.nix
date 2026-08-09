{
  flake.modules.homeManager.noctalia = {
    programs.noctalia.settings.system.monitor = {
      # keep-sorted start
      cpu_poll_seconds = 1.0;
      disk_poll_seconds = 4.0;
      gpu_poll_seconds = 1.0;
      memory_poll_seconds = 4.0;
      network_poll_seconds = 4.0;
      # keep-sorted end
    };
  };
}
