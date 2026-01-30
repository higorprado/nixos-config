{ pkgs, ... }:

{
  programs.fish.enable = true;
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [ 
    "en_US.UTF-8/UTF-8" 
    "pt_BR.UTF-8/UTF-8" 
  ];

  i18n.extraLocaleSettings = {
    LC_CTYPE = "pt_BR.UTF-8";
  };

  users.users.higorprado = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };
  
  system.stateVersion = "25.11";
}
