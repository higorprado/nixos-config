{ ... }:

{
  # Desktop environment settings
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.upower.enable = true;

  # Dank Material Shell configuration (from dms.nix)
  programs = {

    dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/higorprado";
      configFiles = [
        "/home/higorprado/.config/DankMaterialShell/settings.json"
      ];
    };

    dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableVPN = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
    };

    dsearch.enable = true;
  };
}
