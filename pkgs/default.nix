{ pkgs }:

{
  linuwu-sense = pkgs.callPackage ./linuwu-sense.nix { };
  predator-tui = pkgs.callPackage ./predator-tui.nix { };
}
