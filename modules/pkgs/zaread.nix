{
  perSystem = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) makeBinPath;
    inherit
      (pkgs)
      # keep-sorted start
      bashNonInteractive
      fetchFromGitHub
      makeWrapper
      stdenv
      # keep-sorted end
      ;
  in {
    packages.zaread = stdenv.mkDerivation {
      pname = "zaread";
      version = "0-unstable-2025-11-11";

      src = fetchFromGitHub {
        owner = "paoloap";
        repo = "zaread";
        rev = "d4935a72d19bf9c5c035c1363ef798574b6738e7";
        hash = "sha256-4tqi9tvFqB5MZIEluqVmmMWH+hN1c2Jy10C1/iGI6e4=";
      };

      pathAdd = makeBinPath (with pkgs; [
        # keep-sorted start
        libreoffice
        md2pdf
        typst
        zathura
        # keep-sorted end
      ]);

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

      meta = with lib; {
        description = "lightweight document reader";
        homepage = "https://github.com/paoloap/zaread";
        license = licenses.gpl3Only;
        platforms = platforms.unix;
        mainProgram = "zaread";
      };
    };
  };
}
