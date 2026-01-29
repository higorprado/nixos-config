{ ... }:

{
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.upower.enable = true;
}
