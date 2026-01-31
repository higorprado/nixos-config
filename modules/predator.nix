{ config, lib, pkgs, customPkgs, ... }:

let
  # FIX: customPkgs.linuwu-sense provavelmente já é um pacote (derivation) ou não é um path.
  # Para garantir que o "kernel" seja injetado, chama o ARQUIVO do módulo via kernelPackages.
  linuwu-sense = config.boot.kernelPackages.callPackage ../pkgs/linuwu-sense.nix { };

  predator-tui = customPkgs.predator-tui;

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
  # Acer Predator specific settings (from acer-predator.nix)
  boot.extraModulePackages = [ linuwu-sense ];
  boot.kernelModules = [ "acer-wmi" ];

  environment.systemPackages = [ predator-tui ];

  systemd.tmpfiles.rules = [
    "f /sys/firmware/acpi/platform_profile 0664 root wheel - -"
    "z /sys/devices/platform/acer-wmi 0775 root wheel - -"
    "Z /sys/devices/platform/acer-wmi - root wheel - -"
  ];

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

  # LogiOps mouse configuration (from logiops.nix)
  environment.etc."logid.cfg".text = ''
    devices: (
    {
        name: "LIFT VERTICAL ERGONOMIC MOUSE";
        smartshift:
        {
            on: true;
            threshold: 10;
            torque: 30;
        };
        hiresscroll:
        {
            hires: true;
            invert: false;
            target: false;
        };
        dpi: 1000;

        buttons: (
            {
                cid: 0xfd;
                action =
                {
                    type: "Keypress";
                    keys: ["KEY_LEFTMETA", "KEY_O"];
                };
            },
        );
    },
    {
        name: "Wireless Mouse MX Master 3";
        smartshift:
        {
            on: true;
            threshold: 5;
            torque: 10;
        };
        hiresscroll:
        {
            hires: true;
            invert: false;
            target: false;
        };
        dpi: 1000;

        buttons: (
            {
                cid: 0xc4;
                action =
                {
                    type: "Keypress";
                    keys: ["KEY_LEFTMETA", "KEY_O"];
                };
            },
        );
    }
    );
  '';

  systemd.services.logid = {
    description = "LogiOps (logid) for Logitech HID++ devices";
    wantedBy = [ "multi-user.target" ];

    after = [ "bluetooth.service" ];
    wants = [ "bluetooth.service" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid -c /etc/logid.cfg";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  systemd.services."logid-restart@" = {
    description = "Restart logid when Logitech device appears (%I)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block restart logid.service";
    };
  };

  # Udev rules (acer-wmi + logiops)
  services.udev.extraRules = ''
    # Acer WMI
    ACTION=="add", SUBSYSTEM=="platform", DRIVER=="acer-wmi", RUN+="${pkgs.coreutils}/bin/chmod -R g+w /sys/devices/platform/acer-wmi/"
    ACTION=="add", SUBSYSTEM=="platform", DRIVER=="acer-wmi", RUN+="${pkgs.coreutils}/bin/chgrp -R wheel /sys/devices/platform/acer-wmi/"

    # LogiOps - uaccess para dispositivos Logitech
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", TAG+="uaccess"

    # LogiOps - reinicia logid quando dispositivo Logitech aparece
    ACTION=="add|change", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", TAG+="systemd", ENV{SYSTEMD_WANTS}+="logid-restart@%k.service"
  '';
}
