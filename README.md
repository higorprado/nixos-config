# NixOS Configuration (Predator)

This repository contains my NixOS configuration for the host **predator**.

## Build / Switch

From the repository root:

```bash
sudo nixos-rebuild switch --flake .#predator
````

## Repository Layout (recommended)

* `flake.nix`: flake entrypoint and inputs
* `hosts/predator/`: host-specific configuration
* `modules/`: reusable NixOS modules (networking, security, desktop, etc.)
* `home/`: Home Manager configuration for users

## Home Manager

Home Manager is integrated as a NixOS module. The user configuration is managed under `home/higorprado/`.

## DNS (AdGuard)

This setup pins DNS servers and prevents NetworkManager from overriding `/etc/resolv.conf`.

Verify:

```bash
cat /etc/resolv.conf
nmcli dev show | grep -i dns
```

## Disk partitioning (Disko)

Disk layout is defined using `disko`. Use a stable device path (recommended: `/dev/disk/by-id/...`) to avoid accidentally formatting the wrong disk.

List NVMe devices:

```bash
ls -l /dev/disk/by-id/ | grep -i nvme
```

## Notes

* This repository intentionally does **not** store secrets (tokens, keys, VPN credentials).
* Prefer SSH keys for remote access. Avoid password authentication for SSH in public configs.