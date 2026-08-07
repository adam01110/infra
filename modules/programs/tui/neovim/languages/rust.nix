{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.generators) mkLuaInline;
  in {
    programs.nvf.settings.vim = {
      languages.rust = {
        enable = true;
        format.enable = true;

        extensions.crates-nvim = {
          enable = true;

          setupOpts.popup = {
            autofocus = true;
            show_version_date = true;
          };
        };
      };

      lazy.plugins."dyninput.nvim".setupOpts.rust = let
        dyninputRule = language: rule: mkLuaInline "require('dyninput.lang.${language}').${rule}";

        doubleColon = mkLuaInline ''
          function(opt)
            if require("dyninput.lang.rust").double_colon(opt) then
              return true
            end

            local line = vim.api.nvim_buf_get_text(
              opt.buf,
              opt.lnum - 1,
              0,
              opt.lnum - 1,
              opt.col,
              {}
            )[1]

            local segment = line:match("([%a_][%w_]*)$")
            local prefix = segment and line:sub(1, #line - #segment) or ""

            if segment and (
              vim.tbl_contains({ "crate", "self", "Self", "super" }, segment)
              or segment:match("^%u[%w_]+$")
              or prefix:match("::%s*$")
              or prefix:match("=%s*$")
              or prefix:match("^%s*use%s+")
            ) then
              return true
            end

            return false
          end
        '';
      in {
        # keep-sorted start block=yes newline_separated=yes
        "-" = [
          [" -> " (dyninputRule "rust" "thin_arrow")]
          ["_" (dyninputRule "misc" "snake_case")]
        ];

        ":" = [
          ["::" doubleColon]
          [": " (dyninputRule "rust" "single_colon")]
        ];

        "=" = [" => " (dyninputRule "rust" "fat_arrow")];
        # keep-sorted end
      };

      lsp.servers."rust-analyzer".settings."rust-analyzer".rustfmt.overrideCommand = [(getExe pkgs.rustfmt)];
    };
  };
}
