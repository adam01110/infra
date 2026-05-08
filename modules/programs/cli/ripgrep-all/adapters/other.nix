{
  flake.modules.homeManager.ripgrep-all = {
    # keep-sorted start
    lib,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      getExe'
      # keep-sorted end
      ;
    # keep-sorted start
    djvutorga = getExe pkgs.djvutorga-adapter;
    in2csv = getExe' pkgs.csvkit "in2csv";
    pptx2md = getExe pkgs.pptx2md-adapter;
    # keep-sorted end
  in {
    nixpkgs.overlays = [self.overlays.pkgs];

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

      # Convert PPTX presentations with the local markdown adapter.
      {
        name = "pptx";
        version = 1;
        description = "Uses an adapter wrapper to convert PPTX files to markdown";
        extensions = ["pptx"];
        mimetypes = ["application/vnd.openxmlformats-officedocument.presentationml.presentation"];
        binary = pptx2md;
        args = ["--disable-image" "--disable-wmf" "-"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }

      # Extract text from XLSX spreadsheets with in2csv.
      {
        name = "xlsx";
        version = 1;
        description = "Uses in2csv to extract text from XLSX files";
        extensions = ["xlsx"];
        mimetypes = ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"];
        binary = in2csv;
        args = ["\${input_virtual_path}"];
        disabled_by_default = false;
        match_only_by_mime = false;
      }
      # keep-sorted end
    ];
  };
}
