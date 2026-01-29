{ lib, ... }:
{
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  services.fwupd.enable = true;
  services.thermald.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = lib.mkDefault true;
}
