{
  perSystem = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      fetchurl
      runCommand
      # keep-sorted end
      ;
  in {
    # Expanded profile theme ported from the removed visual-refresh root and old class format.
    packages.discord-exp-profile =
      runCommand "expProfile.css" {
        src = fetchurl {
          url = "https://raw.githubusercontent.com/Augenbl1ck/Discord-Styles/7be8b1bd0931de30112ebeeddb2767516d6e08a2/expProfile.css";
          hash = "sha256-kJ5p9CnSUCOPFdmbvryXlQ7Gi6r1P0ykVUdC/HsUKrY=";
        };
      } ''
        substitute $src $out \
          --replace-fail ".visual-refresh {" "body {" \
          --replace-fail ">._9c3bea41fd465666-root .c0bea05627c5dc35-outer" ".outer_P1YEjQ" \
          --replace-fail "._4bd5201c86a2042b-defaultColor.cf48127484dbde85-text-sm/normal _9bfb9a25604068f0-accountNameText," "" \
          --replace-fail "._9c3bea41fd465666-profileAppConnections" ".profileAppConnections_s3DB6Y" \
          --replace-fail "._9bfb9a25604068f0-connectionInfo" ".connectionInfo_O2KI4e" \
          --replace-fail "._37bfcf3d457db7a9-tabBarPanel" ".tabBarPanel_y4ZEM5" \
          --replace-fail "._9c3bea41fd465666-profileBody" ".profileBody_s3DB6Y" \
          --replace-fail "._9bfb9a25604068f0-connection" ".connection_O2KI4e" \
          --replace-fail "._37bfcf3d457db7a9-container" ".container_y4ZEM5" \
          --replace-fail "._49fc18ba07c5025f-focusLock" ".focusLock__KoJTP" \
          --replace-fail "._9bfb9a25604068f0-container" ".container_O2KI4e" \
          --replace-fail "._28fdc02c1d2fcad1-scroller" ".scroller_lRPE7Q" \
          --replace-fail "._9bfb9a25604068f0-metadata" ".metadata_O2KI4e" \
          --replace-fail "._9c3bea41fd465666-profile" ".profile_s3DB6Y" \
          --replace-fail ".be87fdd576f7cb38-section" ".section_zae0GE" \
          --replace-fail ".bf424dc3dc4c8775-section" ".section_NcvRRg" \
          --replace-fail ".c0bea05627c5dc35-inner" ".inner_P1YEjQ" \
          --replace-fail "._0a95c8863b3b3f73-row" ".row_wt-YD5" \
          --replace-fail "._89036700569ec527-row" ".row__Bgzj0"
      '';
  };
}
