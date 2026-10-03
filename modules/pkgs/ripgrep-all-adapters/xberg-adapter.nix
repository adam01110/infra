{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;

    # Xberg lives in the adam01110 NUR, which is not overlaid into perSystem pkgs.
    xberg = inputs.nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}.repos.adam0.xberg;
  in {
    packages.xberg-rga-adapter = writeShellApplication {
      name = "xberg-rga";
      runtimeInputs = [xberg];
      text = ''
        # rga pipes the document to stdin and passes the extension without a dot.
        case "''${1:-}" in
          # keep-sorted start
          docx) mime=application/vnd.openxmlformats-officedocument.wordprocessingml.document ;;
          epub) mime=application/epub+zip ;;
          htm | html) mime=text/html ;;
          pdf) mime=application/pdf ;;
          pptx) mime=application/vnd.openxmlformats-officedocument.presentationml.presentation ;;
          xls) mime=application/vnd.ms-excel ;;
          xlsx) mime=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet ;;
          # keep-sorted end
          *)
            printf 'xberg-rga: unsupported extension %s\n' "''${1:-<none>}" >&2
            exit 1
            ;;
        esac

        exec xberg extract --stdin --mime-type "''${mime}" --content-format markdown --no-config-discovery --no-cache true
      '';
    };
  };
}
