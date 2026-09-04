{inputs, ...}: {
  perSystem = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;
    src = inputs.nixpkgs-crowdsec-blocklist-import.legacyPackages.${system}.crowdsec-blocklist-import.src;
  in {
    packages.crowdsec-blocklist-import = pkgs.python3Packages.buildPythonApplication {
      pname = "crowdsec-blocklist-import";
      version = "3.7.1";
      inherit src;
      pyproject = true;

      build-system = [pkgs.python3Packages.setuptools];
      dependencies = with pkgs.python3Packages; [
        # keep-sorted start
        prometheus-client
        python-dotenv
        requests
        # keep-sorted end
      ];

      nativeCheckInputs = with pkgs.python3Packages; [pytestCheckHook];
      pytestFlags = [
        "-v"
        "test_blocklist_import.py"
      ];
      doCheck = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 blocklist_import.py $out/bin/crowdsec-blocklist-import
        install -Dm644 grafana-dashboard.json $out/share/grafana/dashboards/crowdsec-blocklist-import.json
        runHook postInstall
      '';

      meta = {
        description = "Import threat intelligence from 30+ public blocklists into CrowdSec";
        homepage = "https://github.com/wolffcatskyy/crowdsec-blocklist-import";
        license = lib.licenses.mit;
        mainProgram = "crowdsec-blocklist-import";
      };
    };
  };
}
