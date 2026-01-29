{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.resolvconf.enable = true;
}
