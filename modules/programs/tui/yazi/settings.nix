{
  flake.modules.homeManager.yazi = _: let
    # Memory allocation for image previews in megabytes.
    imageAllocMB = 1024;
  in {
    programs.yazi.settings = {
      # Control memory used by image previews.
      tasks.image_alloc = imageAllocMB * 1024 * 1024;

      # keep-sorted start
      input.cursor_blink = false;
      which.sort_translit = true;
      # keep-sorted end

      # keep-sorted start block=yes newline_separated=yes
      mgr = {
        ratio = [
          1
          2
          2
        ];

        # keep-sorted start
        linemode = "size_mtime";
        scrolloff = 10;
        # keep-sorted end

        # keep-sorted start
        show_hidden = true;
        sort_by = "natural";
        sort_translit = true;
        # keep-sorted end
      };

      open.append_rules = [
        {
          url = "*";
          use = "open";
        }
      ];

      opener.open = [
        {
          desc = "Open";
          for = "linux";
          orphan = true;
          run = "xdg-open %s1";
        }
      ];

      preview = {
        # keep-sorted start
        image_delay = 0;
        image_filter = "lanczos3";
        image_quality = 90;
        # keep-sorted end

        # keep-sorted start
        max_height = 1200;
        max_width = 900;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
