{ inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disko.nix
    ]
    ++ (if builtins.pathExists ./local.nix then [ ./local.nix ] else [])
    ++ [
      ../../modules/system.nix
      ../../modules/hardware.nix
      ../../modules/security.nix
      ../../modules/desktop.nix
      ../../modules/predator.nix
      ../../modules/packages.nix
      ../../home/higorprado
    ];

  networking.hostName = "predator";

  boot.loader = {
    efi = {
      canTouchEfiVariables = false;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      devices = [ "nodev" ];
    };
  };
}
