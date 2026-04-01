{ config, pkgs, ... }:

{
  # 1. Enable iSCSI daemon (Crucial for Longhorn)
  services.openiscsi = {
    enable = true;
    name = "iqn.2026-03.com.proxy-m:${config.networking.hostName}";
  };

  # 2. Enable NFS support (For RWX volumes)
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  # 3. Load required kernel modules
  boot.kernelModules = [
    "iscsi_tcp"
    "dm_crypt"
    "dm_multipath"
  ];

  # 4. Ensure necessary tools are available in the system path
  environment.systemPackages = with pkgs; [
    openiscsi
    nfs-utils
    util-linux # for findmnt, etc.
    bash
  ];

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
    "L+ /usr/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
  ];
}
