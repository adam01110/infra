{
  flake.modules.homeManager.eza = {config, ...}: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.eza.theme = with colors; {
      # keep-sorted start block=yes newline_separated=yes
      colourful = true;

      # Colors by file extension category.
      file_type = {
        # keep-sorted start
        build = base04;
        compiled = base0D;
        compressed = base0E;
        crypto = base04;
        document = base05;
        image = base0A;
        lossless = base0C;
        music = base0B;
        source = base0D;
        temp = base08;
        video = base08;
        # keep-sorted end
      };

      # File kind colors.
      filekinds = {
        # keep-sorted start
        block_device = base08;
        char_device = base08;
        directory = base0D;
        executable = base0B;
        mount_point = base09;
        normal = base05;
        pipe = base04;
        socket = base03;
        special = base0E;
        symlink = base0C;
        # keep-sorted end
      };

      # Git status colors.
      git = {
        # keep-sorted start
        conflicted = base08;
        deleted = base08;
        ignored = base04;
        modified = base0A;
        new = base0B;
        renamed = base0C;
        typechange = base0E;
        # keep-sorted end
      };

      # Git repo metadata colors.
      git_repo = {
        # keep-sorted start
        branch_main = base05;
        branch_other = base0E;
        git_clean = base0B;
        git_dirty = base08;
        # keep-sorted end
      };

      # Link count and hardlink colors.
      links = {
        # keep-sorted start
        multi_link_file = base09;
        normal = base0C;
        # keep-sorted end
      };

      # Permission bit colors.
      perms = {
        # keep-sorted start
        attribute = base04;
        group_execute = base0B;
        group_read = base05;
        group_write = base0A;
        other_execute = base0B;
        other_read = base04;
        other_write = base0A;
        special_other = base04;
        special_user_file = base0E;
        user_execute_file = base0B;
        user_execute_other = base0B;
        user_read = base05;
        user_write = base0A;
        # keep-sorted end
      };

      # Selinux security context colors.
      security_context = {
        # keep-sorted start
        colon = base04;
        range = base0E;
        role = base0E;
        typ = base03;
        user = base05;
        # keep-sorted end
      };

      # Size column colors by unit and magnitude.
      size = {
        # keep-sorted start
        major = base04;
        minor = base0C;
        number_byte = base05;
        number_giga = base0E;
        number_huge = base0E;
        number_kilo = base05;
        number_mega = base0D;
        unit_byte = base04;
        unit_giga = base0E;
        unit_huge = base09;
        unit_kilo = base0D;
        unit_mega = base0E;
        # keep-sorted end
      };

      # User and group colors.
      users = {
        # keep-sorted start
        group_other = base04;
        group_root = base08;
        group_yours = base05;
        user_other = base0E;
        user_root = base08;
        user_you = base05;
        # keep-sorted end
      };
      # keep-sorted end

      # Misc token colors.
      # keep-sorted start
      blocks = base03;
      date = base0A;
      flags = base0E;
      header = base05;
      inode = base04;
      octal = base0C;
      punctuation = base04;
      # keep-sorted end

      # Symlink visuals.
      # keep-sorted start
      broken_path_overlay = base04;
      broken_symlink = base08;
      control_char = base0D;
      symlink_path = base0C;
      # keep-sorted end
    };
  };
}
