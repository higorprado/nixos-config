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
      sha256 = "sha256-RmZvPomNzCGdePax8qLjolZq5SRzxKg6TpDEYvH7ic0=";
    };

    vendorHash = "sha256-lKSr05aeK+HBxJKIbBPSesYpokf6D2Yol8p4OHHjNQ8=";
  };
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
}
