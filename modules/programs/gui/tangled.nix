{
  flake.modules.homeManager.tangled = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      installShellFiles
      runCommand
      # keep-sorted end
      ;

    tang = pkgs.nur.repos.adam0.tang;
    tang-completions = runCommand "tang-completions" {nativeBuildInputs = [installShellFiles tang];} ''
      installShellCompletion --cmd tang \
        --bash <(tang completion bash) \
        --fish <(tang completion fish) \
        --zsh <(tang completion zsh)
    '';
  in {
    home.packages = [tang];

    programs.bash.initExtra = ''
      source ${tang-completions}/share/bash-completion/completions/tang
    '';

    programs.fish.interactiveShellInit = ''
      source ${tang-completions}/share/fish/vendor_completions.d/tang.fish
    '';

    programs.zsh.initContent = ''
      source ${tang-completions}/share/zsh/site-functions/_tang
    '';
  };
}
