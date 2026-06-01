{
  flake.modules.homeManager.ripgrep-all = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    # keep-sorted start
    fastgron = getExe pkgs.fastgron;
    qq = getExe pkgs.nur.repos.adam0.qq-jfryy;
    # keep-sorted end
  in {
    programs.ripgrep-all.custom_adapters = [
      # keep-sorted start block=yes newline_separated=yes
      # Convert JSON into line-oriented assignments for grep.
      {
        name = "json";
        version = 1;
        description = "Transform JSON into discrete JS assignments";
        extensions = ["json"];
        mimetypes = ["application/json" "text/json"];
        binary = fastgron;
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Convert JSONC into fastgron-style assignments through qq.
      {
        name = "jsonc";
        version = 1;
        description = "Transform Markup files into greppable assignments";
        extensions = ["jsonc"];
        mimetypes = ["application/jsonc" "text/jsonc"];
        binary = qq;
        args = ["--monochrome-output" "--output" "${fastgron}" "--input" "jsonc"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Convert TOML into fastgron-style assignments through qq.
      {
        name = "toml";
        version = 1;
        description = "Transform Markup files into greppable assignments";
        extensions = ["toml"];
        mimetypes = ["application/toml" "text/toml"];
        binary = qq;
        args = ["--monochrome-output" "--output" "${fastgron}" "--input" "toml"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Convert XML into fastgron-style assignments through qq.
      {
        name = "xml";
        version = 1;
        description = "Transform Markup files into greppable assignments";
        extensions = ["xml"];
        mimetypes = ["application/xml" "text/xml"];
        binary = qq;
        args = ["--monochrome-output" "--output" "${fastgron}" "--input" "xml"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Convert YAML into fastgron-style assignments through qq.
      {
        name = "yaml";
        version = 1;
        description = "Transform Markup files into greppable assignments";
        extensions = ["yml" "yaml"];
        mimetypes = ["application/yaml" "text/yaml"];
        binary = qq;
        args = ["--monochrome-output" "--output" "${fastgron}" "--input" "yaml"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }
      # keep-sorted end
    ];
  };
}
