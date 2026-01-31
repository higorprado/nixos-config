{ config, lib, pkgs, ... }:

{
  # User, locale, timezone (from base.nix)
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

  # Kernel version (from kernel.nix)
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Nix settings (from nix-settings.nix)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Performance settings (from performance.nix)
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  services.fwupd.enable = true;
  services.thermald.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = false;
}
