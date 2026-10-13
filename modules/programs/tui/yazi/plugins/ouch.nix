{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.ouch = pkgs.yaziPlugins.ouch;

      keymap.mgr.prepend_keymap = [
        {
          on = ["C"];
          run = "plugin ouch";
          desc = "Compress with ouch";
        }
      ];

      settings = {
        plugin.prepend_previewers = [
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch --show-file-icons";
          }
        ];

        opener.extract = [
          {
            run = "ouch d -y %s";
            desc = "Extract here with ouch";
          }
        ];
      };
    };
  };
}
