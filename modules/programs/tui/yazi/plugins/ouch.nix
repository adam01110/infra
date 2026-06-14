{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.ouch = pkgs.yaziPlugins.ouch;

      settings = {
        plugin.prepend_previewers = [
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch --show-file-icons";
          }
        ];

        mgr.prepend_keymap = {
          on = ["C"];
          run = "plugin ouch";
          desc = "Compress with ouch";
        };

        opener.extract = [
          # keep-sorted start block=yes newline_separated=yes
          {
            run = "ouch d -y %*";
            desc = "Extract here with ouch";
            for = "windows";
          }

          {
            run = "ouch d -y '$@'";
            desc = "Extract here with ouch";
            for = "unix";
          }
          # keep-sorted end
        ];
      };
    };
  };
}
