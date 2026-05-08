let
  zaread = {
    # keep-sorted start
    bashNonInteractive,
    calibre,
    fetchFromGitHub,
    lib,
    libreoffice,
    makeWrapper,
    md2pdf,
    stdenv,
    typst,
    zathura,
    # keep-sorted end
    libreofficeSupport ? true,
    markdownSupport ? true,
    mobiSupport ? false,
    typstSupport ? true,
  }:
    stdenv.mkDerivation {
      pname = "zaread";
      version = "0-unstable-2025-11-11";

      src = fetchFromGitHub {
        owner = "paoloap";
        repo = "zaread";
        rev = "d4935a72d19bf9c5c035c1363ef798574b6738e7";
        hash = "sha256-4tqi9tvFqB5MZIEluqVmmMWH+hN1c2Jy10C1/iGI6e4=";
      };

      pathAdd = lib.makeBinPath (
        [zathura]
        ++ lib.optionals libreofficeSupport [libreoffice]
        ++ lib.optionals markdownSupport [md2pdf]
        ++ lib.optionals mobiSupport [calibre]
        ++ lib.optionals typstSupport [typst]
      );

      nativeBuildInputs = [makeWrapper];
      buildInputs = [bashNonInteractive];
      dontBuild = true;

      installPhase = ''
        install -Dm 755 $src/zaread $out/bin/zaread
        runHook postInstall
      '';

      postInstall = ''
        wrapProgram $out/bin/zaread --prefix PATH : $pathAdd
      '';

      meta = {
        description = "lightweight document reader";
        homepage = "https://github.com/paoloap/zaread";
        license = lib.licenses.gpl3Only;
        platforms = lib.platforms.unix;
        mainProgram = "zaread";
      };
    };
in {
  perSystem = {pkgs, ...}: {
    packages.zaread = pkgs.callPackage zaread {};
  };
}
