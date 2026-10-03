{
  flake.modules.homeManager.ripgrep-all = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      # keep-sorted end
      ;
    # keep-sorted start
    djvutorga = getExe pkgs.djvutorga-adapter;
    xbergRga = getExe pkgs.xberg-rga-adapter;
    # keep-sorted end
  in {
    programs.ripgrep-all.custom_adapters = [
      # keep-sorted start block=yes newline_separated=yes
      # Extract plain text from DjVu files with a local wrapper.
      {
        name = "djvu";
        version = 1;
        description = "Uses djvused to extract plain text from DJVU files";
        extensions = ["djvu"];
        mimetypes = ["image/vnd.djvu"];
        binary = djvutorga;
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Prefer one stdin converter over the overlapping built-in adapters.
      {
        name = "xberg";
        version = 1;
        description = "Uses Xberg to convert documents to Markdown";
        extensions = [
          # keep-sorted start
          "docx"
          "epub"
          "htm"
          "html"
          "pdf"
          "pptx"
          "xls"
          "xlsx"
          # keep-sorted end
        ];
        mimetypes = [
          # keep-sorted start
          "application/epub+zip"
          "application/pdf"
          "application/vnd.ms-excel"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "text/html"
          # keep-sorted end
        ];
        binary = xbergRga;
        args = ["\${input_file_extension}"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }
      # keep-sorted end
    ];
  };
}
