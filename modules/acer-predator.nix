{ config, pkgs, ... }:

let
  linuwu-sense = config.boot.kernelPackages.callPackage
    ({ stdenv, kernel, fetchFromGitHub }:
      stdenv.mkDerivation rec {
        pname = "linuwu-sense";
        version = "main";

        src = fetchFromGitHub {
          owner = "higorprado";
          repo = "Linuwu-Sense";
          rev = "main";
          sha256 = "0nq5ri98h2j8ylqrwmqhdvvj9kkhjxv638qibhkhzrfx5ilwsaxx";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies;

        makeFlags = [
          "KERNELRELEASE=${kernel.modDirVersion}"
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
          "INSTALL_MOD_PATH=$(out)"
        ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
          find . -name "*.ko" -exec cp {} $out/lib/modules/${kernel.modDirVersion}/extra/ \;
          runHook postInstall
        '';
      }) { };

  predator-tui = pkgs.buildGoModule rec {
    pname = "predator-tui";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "higorprado";
      repo = "predator-tui";
      rev = "main";
      sha256 = "sha256-luRM+nPfuYXtl4v3m4LAYZQEMuyR3lydaUBPBdlhWz0=";
    };

    vendorHash = "sha256-lKSr05aeK+HBxJKIbBPSesYpokf6D2Yol8p4OHHjNQ8=";
  };

  setPlatformProfileScript = pkgs.writeShellScript "set-platform-profile" ''
    set -euo pipefail

    PROFILE_FILE="/sys/firmware/acpi/platform_profile"
    CHOICES_FILE="/sys/firmware/acpi/platform_profile_choices"

    # Espera o sysfs aparecer (módulos / ACPI)
    for i in $(seq 1 50); do
      if [ -w "$PROFILE_FILE" ]; then
        break
      fi
      sleep 0.1
    done

    if [ ! -w "$PROFILE_FILE" ]; then
      echo "platform_profile: arquivo não está disponível/escrevível: $PROFILE_FILE" >&2
      exit 0
    fi

    choices=""
    if [ -r "$CHOICES_FILE" ]; then
      choices="$(cat "$CHOICES_FILE" || true)"
    fi

    pick_and_set() {
      local target="$1"
      if [ -n "$choices" ]; then
        echo "$choices" | tr ' ' '\n' | grep -qx "$target" || return 1
      fi
      echo "$target" > "$PROFILE_FILE"
      echo "platform_profile setado para: $target"
      return 0
    }

    # Preferido: balanced-performance
    pick_and_set "balanced-performance" || \
    pick_and_set "performance" || \
    pick_and_set "balanced" || \
    (echo "platform_profile: nenhum profile esperado encontrado. choices='$choices'" >&2; exit 0)
  '';
in
{
  boot.extraModulePackages = [ linuwu-sense ];
  boot.kernelModules = [ "acer-wmi" ];

  environment.systemPackages = [ predator-tui ];

  systemd.tmpfiles.rules = [
    "f /sys/firmware/acpi/platform_profile 0664 root wheel - -"
    "z /sys/devices/platform/acer-wmi 0775 root wheel - -"
    "Z /sys/devices/platform/acer-wmi - root wheel - -"
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="platform", DRIVER=="acer-wmi", RUN+="${pkgs.coreutils}/bin/chmod -R g+w /sys/devices/platform/acer-wmi/"
    ACTION=="add", SUBSYSTEM=="platform", DRIVER=="acer-wmi", RUN+="${pkgs.coreutils}/bin/chgrp -R wheel /sys/devices/platform/acer-wmi/"
  '';

  systemd.services.set-platform-profile = {
    description = "Set ACPI platform_profile (balanced-performance)";
    wantedBy = [ "multi-user.target" ];

    after = [ "systemd-modules-load.service" "sysinit.target" ];
    wants = [ "systemd-modules-load.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = setPlatformProfileScript;
    };
  };
}
