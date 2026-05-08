{
  flake.modules.homeManager.zathura = {lib, ...}: let
    inherit
      (lib.self)
      # keep-sorted start
      mimeAppDefaults
      mimeAppEntries
      # keep-sorted end
      ;
  in {
    xdg.mimeApps.defaultApplications = mimeAppDefaults (
      # keep-sorted start block=yes
      (mimeAppEntries "application" "org.pwmt.zathura-pdf-mupdf.desktop" [
        # keep-sorted start
        "epub+zip"
        "oxps"
        "pdf"
        "vnd.ms-xpsdocument"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "org.pwmt.zathura-cb.desktop" [
        # keep-sorted start
        "vnd.comicbook+zip"
        "vnd.comicbook-rar"
        "x-cb7"
        "x-cbt"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "org.pwmt.zathura-ps.desktop" [
        "postscript"
      ])
      ++ (mimeAppEntries "application" "zaread.desktop" [
        # keep-sorted start
        "msword"
        "msword-template"
        "rtf"
        "vnd.apple.keynote"
        "vnd.apple.numbers"
        "vnd.apple.pages"
        "vnd.ms-excel"
        "vnd.ms-excel.sheet.binary.macroEnabled.12"
        "vnd.ms-excel.sheet.macroEnabled.12"
        "vnd.ms-excel.template.macroEnabled.12"
        "vnd.ms-powerpoint"
        "vnd.ms-powerpoint.presentation.macroEnabled.12"
        "vnd.ms-powerpoint.slideshow.macroEnabled.12"
        "vnd.ms-powerpoint.template.macroEnabled.12"
        "vnd.ms-visio.drawing.macroEnabled.main+xml"
        "vnd.ms-visio.drawing.main+xml"
        "vnd.ms-visio.stencil.macroEnabled.main+xml"
        "vnd.ms-visio.stencil.main+xml"
        "vnd.ms-visio.template.macroEnabled.main+xml"
        "vnd.ms-visio.template.main+xml"
        "vnd.ms-word.document.macroEnabled.12"
        "vnd.ms-word.template.macroEnabled.12"
        "vnd.oasis.opendocument.graphics"
        "vnd.oasis.opendocument.presentation"
        "vnd.oasis.opendocument.presentation-flat-xml"
        "vnd.oasis.opendocument.presentation-template"
        "vnd.oasis.opendocument.spreadsheet"
        "vnd.oasis.opendocument.spreadsheet-flat-xml"
        "vnd.oasis.opendocument.spreadsheet-template"
        "vnd.oasis.opendocument.text"
        "vnd.oasis.opendocument.text-flat-xml"
        "vnd.oasis.opendocument.text-template"
        "vnd.openxmlformats-officedocument.presentationml.presentation"
        "vnd.openxmlformats-officedocument.presentationml.slideshow"
        "vnd.openxmlformats-officedocument.presentationml.template"
        "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        "vnd.openxmlformats-officedocument.spreadsheetml.template"
        "vnd.openxmlformats-officedocument.wordprocessingml.document"
        "vnd.openxmlformats-officedocument.wordprocessingml.template"
        "vnd.sun.xml.calc"
        "vnd.sun.xml.impress"
        "vnd.sun.xml.writer"
        "vnd.sun.xml.writer.template"
        "x-hwp"
        "x-mobipocket-ebook"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "image" "org.pwmt.zathura-djvu.desktop" [
        # keep-sorted start
        "vnd.djvu"
        "vnd.djvu+multipage"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "image" "org.pwmt.zathura-ps.desktop" [
        "x-eps"
      ])
      ++ (mimeAppEntries "text" "zaread.desktop" [
        # keep-sorted start
        "csv"
        "markdown"
        "x-markdown"
        "x-typst"
        # keep-sorted end
      ])
      # keep-sorted end
    );
  };
}
