{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
      ${pkgs.mise}/bin/mise activate fish | source
    '';
  };
}
