{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.logiops
  ];

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
      ExecStart = "/run/current-system/sw/bin/systemctl --no-block restart logid.service";
    };
  };

  services.udev.extraRules = ''
    # Mantém seu uaccess (ok)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", TAG+="uaccess"

    # Quando surgir/atualizar um hidraw da Logitech, dispara o restart do logid.
    ACTION=="add|change", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", TAG+="systemd", ENV{SYSTEMD_WANTS}+="logid-restart@%k.service"
  '';
}
