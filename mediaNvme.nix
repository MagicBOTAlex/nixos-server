{ pkgs, lib, config, ... }:

let
  nvmeServerIp = "192.168.50.59";
  port = "4420";
  diskShares = [ "disk1" "disk2" "disk3" "disk4" ];

  # Shell commands to connect/disconnect each subsystem via nvme-cli
  connectCommands = map
    (share: ''
      ${pkgs.nvme-cli}/bin/nvme connect \
        -t tcp \
        -a ${nvmeServerIp} \
        -s ${port} \
        -n "nqn.2026-07.org.nvmexpress:${share}" || true
    '')
    diskShares;

  disconnectCommands = map
    (share: ''
      ${pkgs.nvme-cli}/bin/nvme disconnect \
        -n "nqn.2026-07.org.nvmexpress:${share}" || true
    '')
    diskShares;

  # Mount filesystems by subsystem path (created automatically in /dev/disk/by-nqn/)
  nvmeMounts = builtins.listToAttrs (map
    (share: {
      name = "/mnt/remote/${share}";
      value = {
        device = "/dev/disk/by-nqn/nqn.2026-07.org.nvmexpress:${share}";
        fsType = "ext4"; # Matches the ext4 filesystem on the target disks
        options = [
          "defaults"
          "nofail"
          "_netdev"
          "x-systemd.requires=nvme-connect.service" # Wait until NVMe targets are connected
        ];
      };
    })
    diskShares);

in
{
  # 1. Load the TCP transport module for NVMe-oF
  boot.kernelModules = [ "nvme-tcp" ];

  # 2. System service to connect to the target drives on boot
  systemd.services.nvme-connect = {
    description = "Connect to NVMe-oF Target Subsystems";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [ pkgs.nvme-cli ];

    script = pkgs.lib.concatStringsSep "\n" connectCommands;
    execStop = pkgs.lib.concatStringsSep "\n" disconnectCommands;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Retry if network isn't quite ready on boot
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # 3. Mount the remote NVMe block devices locally
  fileSystems = nvmeMounts;

  # Include nvme-cli for manual commands (e.g. `sudo nvme list`)
  environment.systemPackages = [ pkgs.nvme-cli ];
}
