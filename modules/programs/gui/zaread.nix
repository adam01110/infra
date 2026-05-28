{
  flake.modules.homeManager.zaread = {
    # keep-sorted start
    lib,
    pkgs,
    self,
    # keep-sorted end
    ...
  }: {
    imports = [self.modules.homeManager.zathura];

    # keep-sorted start block=yes newline_separated=yes
    home.packages = [pkgs.zaread];

    xdg.desktopEntries.zaread = {
      name = "zaread";
      genericName = "document viewer";
      comment = "Open documents via zathura with format conversion.";

      exec = "${lib.getExe pkgs.zaread} %U";
      terminal = false;

      categories = [
        # keep-sorted start
        "Office"
        "Viewer"
        # keep-sorted end
      ];

      # Claim office and ebook formats that zaread converts before handing off to zathura.
      mimeType = [
        # keep-sorted start
        "application/msword"
        "application/msword-template"
        "application/rtf"
        "application/vnd.apple.keynote"
        "application/vnd.apple.numbers"
        "application/vnd.apple.pages"
        "application/vnd.ms-excel"
        "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
        "application/vnd.ms-excel.sheet.macroEnabled.12"
        "application/vnd.ms-excel.template.macroEnabled.12"
        "application/vnd.ms-powerpoint"
        "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
        "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
        "application/vnd.ms-powerpoint.template.macroEnabled.12"
        "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
        "application/vnd.ms-visio.drawing.main+xml"
        "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
        "application/vnd.ms-visio.stencil.main+xml"
        "application/vnd.ms-visio.template.macroEnabled.main+xml"
        "application/vnd.ms-visio.template.main+xml"
        "application/vnd.ms-word.document.macroEnabled.12"
        "application/vnd.ms-word.template.macroEnabled.12"
        "application/vnd.oasis.opendocument.graphics"
        "application/vnd.oasis.opendocument.presentation"
        "application/vnd.oasis.opendocument.presentation-flat-xml"
        "application/vnd.oasis.opendocument.presentation-template"
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.oasis.opendocument.spreadsheet-flat-xml"
        "application/vnd.oasis.opendocument.spreadsheet-template"
        "application/vnd.oasis.opendocument.text"
        "application/vnd.oasis.opendocument.text-flat-xml"
        "application/vnd.oasis.opendocument.text-template"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
        "application/vnd.openxmlformats-officedocument.presentationml.template"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
        "application/vnd.sun.xml.calc"
        "application/vnd.sun.xml.impress"
        "application/vnd.sun.xml.writer"
        "application/vnd.sun.xml.writer.template"
        "application/x-hwp"
        "application/x-mobipocket-ebook"
        "text/csv"
        "text/markdown"
        "text/x-markdown"
        "text/x-typst"
        # keep-sorted end
      ];
    };
    # keep-sorted end
  };
}
