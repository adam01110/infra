{inputs, ...}: {
  flake-file.inputs.tg = {
    url = "git+https://tangled.org/aly.codes/tg";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.tangled = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      installShellFiles
      runCommand
      # keep-sorted end
      ;

    tg = inputs.tg.packages.${pkgs.stdenv.hostPlatform.system}.tg;
    tg-completions = runCommand "tg-completions" {nativeBuildInputs = [installShellFiles tg];} ''
      installShellCompletion --cmd tg \
        --bash <(tg completion bash) \
        --fish <(tg completion fish) \
        --zsh <(tg completion zsh)
    '';
  in {
    home.packages = [tg];

    programs.bash.initExtra = ''
      source ${tg-completions}/share/bash-completion/completions/tg
    '';

    programs.fish.interactiveShellInit = ''
      source ${tg-completions}/share/fish/vendor_completions.d/tg.fish
    '';

    programs.zsh.initContent = ''
      source ${tg-completions}/share/zsh/site-functions/_tg
    '';
  };
}
