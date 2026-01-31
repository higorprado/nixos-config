{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      nb = "nix build --log-format internal-json -v .#nixosConfigurations.predator.config.system.build.toplevel 2>&1 | nom --json";
      ns = "sudo ./result/bin/switch-to-configuration switch";
      # hms = "home-manager switch --flake .#predator";
    };
    interactiveShellInit = ''
      starship init fish | source
      ${pkgs.mise}/bin/mise activate fish | source
    '';
  };
}
