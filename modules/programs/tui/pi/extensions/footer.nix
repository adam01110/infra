{
  flake.modules.homeManager.pi = {pkgs, ...}: let
    jsonFormat = pkgs.formats.json {};
  in {
    home.file.".pi/agent/extensions/pi-footer.json".source = jsonFormat.generate "pi-footer.json" {
      iconMode = "nerd";

      lines = [
        [
          {
            id = "model";
            type = "model-provider";
          }

          {
            id = "thinking";
            type = "thinking-level";
          }

          {
            id = "verbosity";
            type = "text-verbosity";
          }

          {
            id = "tokens";
            type = "tokens";
            options.tokenFormatStyle = "compact";
          }

          {
            id = "cost";
            type = "cost";
          }

          {
            id = "time";
            type = "total-time";
          }

          {
            id = "context";
            type = "context-bar";
            options = {
              contextBarMode = "medium";
              fg = "blue";
              tokenFormatStyle = "compact";
            };
          }
        ]
      ];
    };
  };
}
