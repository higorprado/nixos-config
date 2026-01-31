{ config, pkgs, ... }:

{
  # Audio configuration (from audio.nix)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Input methods (from input.nix)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-gtk ];
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
    model = "pc105";
  };

  console.keyMap = "us-acentos";

  # NVIDIA GPU (from nvidia.nix)
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics.enable = true;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-wayland-vram-fix.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
        {
          pattern = {
            feature = "procname";
            matches = ".quickshell-wra";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];

      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

  # Networking (from networking.nix)
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
