{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication writeText;

    dashboardStatusFilter = writeText "dashboard-status-filter.lua" ''
      local function truncate_ansi(line, max)
        local out = {}
        local visible = 0
        local i = 1

        while i <= #line do
          local char = line:sub(i, i)

          if char == "\27" then
            local finish = line:find("m", i, true)
            if not finish then
              break
            end

            out[#out + 1] = line:sub(i, finish)
            i = finish + 1
          else
            if visible >= max then
              out[#out + 1] = "...\27[0m"
              break
            end

            out[#out + 1] = char
            visible = visible + 1
            i = i + 1
          end
        end

        return table.concat(out)
      end

      local seen = 0
      for line in io.lines() do
        if seen == 6 then
          break
        end

        local plain = line:gsub("\27%[[0-9;]*m", "")
        print(#plain > 48 and truncate_ansi(line, 45) or line)
        seen = seen + 1
      end

      if seen == 0 then
        print("No jj changes")
      end
    '';
  in {
    packages.dashboard-vcs-status = writeShellApplication {
      name = "dashboard-vcs-status";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        gawk
        git
        jujutsu
        lua
        # keep-sorted end
      ];
      text = ''
        if jj root >/dev/null 2>&1; then
          jj --color always status | lua ${dashboardStatusFilter}
        elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          git -c color.status=always status --short --branch --renames \
            | awk 'NR <= 6 { print; seen = 1 } END { if (!seen) print "No git changes" }'
        else
          printf '\n\n\n\n\n\n'
        fi
      '';
    };
  };
}
