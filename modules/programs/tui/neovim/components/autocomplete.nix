{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    blinkGitTokenPath = config.sops.secrets.github_token.path;
  in {
    sops.secrets.github_token = {};

    programs.nvf.settings.vim = {
      snippets.luasnip.enable = true;

      autocomplete.blink-cmp = {
        enable = true;
        friendly-snippets.enable = true;

        sourcePlugins = {
          # keep-sorted start block=yes newline_separated=yes
          conventional_commits = {
            enable = true;
            module = "blink-cmp-conventional-commits";
            package = pkgs.vimPlugins.blink-cmp-conventional-commits;
          };

          git = {
            enable = true;
            module = "blink-cmp-git";
            package = pkgs.vimPlugins.blink-cmp-git;
          };

          npm = {
            enable = true;
            module = "blink-cmp-npm";
            package = pkgs.vimPlugins.blink-cmp-npm-nvim;
          };

          ripgrep.enable = true;

          words = {
            enable = true;
            module = "blink-cmp-words.dictionary";
            package = pkgs.vimPlugins.blink-cmp-words;
          };
          # keep-sorted end
        };

        setupOpts = {
          keymap.preset = "default";

          # keep-sorted start
          cmdline.completion.menu.auto_show = true;
          fuzzy.implementation = "prefer_rust_with_warning";
          # keep-sorted end

          completion = {
            # keep-sorted start
            documentation.auto_show = true;
            ghost_text.enabled = true;
            # keep-sorted end

            keyword.range = "full";
          };

          signature = {
            enabled = true;

            # keep-sorted start
            show_on_insert = true;
            show_on_keyword = true;
            # keep-sorted end
          };

          sources.providers = let
            commitSourceEnabled = mkLuaInline ''
              function()
                return vim.tbl_contains({ "gitcommit", "jjdescription" }, vim.bo.filetype)
              end
            '';

            githubToken = mkLuaInline ''
              function()
                return vim.fn.readfile("${blinkGitTokenPath}")[1]
              end
            '';
          in {
            conventional_commits.enabled = commitSourceEnabled;

            git = {
              enabled = commitSourceEnabled;
              opts = {
                git_centers.github = {
                  # keep-sorted start
                  issue.get_token = githubToken;
                  mention.get_token = githubToken;
                  pull_request.get_token = githubToken;
                  # keep-sorted end
                };

                kind_icons = let
                  lockIcon = "";
                in {
                  # keep-sorted start
                  lockedIssue = lockIcon;
                  lockedPR = lockIcon;
                  # keep-sorted end
                };
              };
            };

            npm.enabled = mkLuaInline ''
              function()
                return vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "package.json"
              end
            '';

            words.enabled = mkLuaInline ''
              function()
                return vim.tbl_contains({ "gitcommit", "jjdescription", "markdown" }, vim.bo.filetype)
              end
            '';
          };

          term = {
            enabled = true;

            completion = {
              # keep-sorted start
              ghost_text.enabled = true;
              menu.auto_show = true;
              # keep-sorted end

              list.selection = {
                # keep-sorted start
                auto_insert = true;
                preselect = true;
                # keep-sorted end
              };
            };
          };
        };
      };
    };
  };
}
