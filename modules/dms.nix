programs.dank-material-shell = {
  enable = true;

  systemd = {
    enable = false;
    restartIfChanged = true;
  };

  enableSystemMonitoring = true;
  enableVPN = true;
  enableDynamicTheming = true;
  enableAudioWavelength = true;
  enableCalendarEvents = true;
  enableClipboardPaste = true;
};
