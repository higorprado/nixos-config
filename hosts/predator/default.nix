{ inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disko.nix
    ]
    ++ (if builtins.pathExists ./local.nix then [ ./local.nix ] else [])
    ++ [
      ../../modules/base.nix
      ../../modules/kernel.nix
      ../../modules/nix-settings.nix
      ../../modules/security.nix
      ../../modules/input.nix
      ../../modules/audio.nix
      ../../modules/nvidia.nix
      ../../modules/desktop.nix
      ../../modules/packages.nix
      ../../modules/acer-predator.nix
      ../../modules/dms.nix
      ../../modules/performance.nix
      ../../modules/networking.nix
      ../../modules/luks.nix
      ../../modules/logiops.nix
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
