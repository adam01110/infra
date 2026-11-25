{
  flake.aspects.neovim.homeManager = {
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
      languages.docker = {
        enable = true;
        extraDiagnostics.enable = true;
      };

      # Nvf has no droast preset, so it runs beside hadolint as a custom linter.
      diagnostics.nvim-lint = {
        linters_by_ft.dockerfile = ["droast"];

        linters.droast = {
          cmd = getExe pkgs.nur.repos.adam0.droast;
          # The .dockerignore check reports on files outside the buffer.
          args = ["--format" "json" "--no-fail" "--no-roast" "--check-dockerignore=false"];
          stream = "stdout";

          # Findings use 1-based positions; line 0 marks file-level findings.
          # JSON keeps the roast field under --no-roast, so it is ignored here.
          parser = mkLuaInline ''
            function(output)
              local ok, payload = pcall(vim.json.decode, output)
              if not ok or type(payload) ~= "table" then
                return {}
              end

              local severities = {
                ERROR = vim.diagnostic.severity.ERROR,
                WARN = vim.diagnostic.severity.WARN,
                INFO = vim.diagnostic.severity.INFO,
              }
              local diagnostics = {}
              for _, finding in ipairs(payload.findings or {}) do
                local lnum = math.max((finding.line or 1) - 1, 0)
                local col = math.max((finding.column or 1) - 1, 0)
                table.insert(diagnostics, {
                  lnum = lnum,
                  col = col,
                  end_lnum = finding.end_line and math.max(finding.end_line - 1, lnum) or nil,
                  end_col = finding.end_column and math.max(finding.end_column - 1, col) or nil,
                  severity = severities[finding.severity] or vim.diagnostic.severity.WARN,
                  source = "droast",
                  code = finding.rule,
                  message = finding.message,
                })
              end
              return diagnostics
            end
          '';
        };
      };
    };
  };
}
