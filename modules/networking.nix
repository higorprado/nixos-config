{ ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  
  networking.nameservers = [ "192.168.1.28" ];
  
  networking.dhcpcd.extraConfig = ''
    nohook resolv.conf
  '';
  
  environment.etc."resolv.conf".text = ''
    nameserver 192.168.1.28
  '';
}