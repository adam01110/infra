{
  flake.modules.homeManager.starship = {
    programs.starship.settings = {
      # keep-sorted start block=yes newline_separated=yes
      fossil_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "fg:magenta bold";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
        symbol = " ";
        style = "bg:base01 fg:magenta bold";
      };

      git_commit = {
        format = "[\\($hash$tag\\)]($style)";
        style = "bg:base01 fg:green bold";
        tag_disabled = false;
        only_detached = false;
        tag_symbol = "  ";
      };

      git_state = {
        format = "[ $state( $progress_current/$progress_total)]($style)";
        style = "bg:base01 fg:yellow bold";
        # keep-sorted start
        am = "am";
        am_or_rebase = "am/rebase";
        bisect = "bisecting";
        cherry_pick = "cherry-picking";
        merge = "merging";
        rebase = "rebasing";
        revert = "reverting";
        # keep-sorted end
      };

      git_status = {
        format = "([ \\[$all_status$ahead_behind\\]]($style))";
        style = "bg:base01 fg:base08 bold";
        deleted = "";
      };
      # keep-sorted end
    };
  };
}
