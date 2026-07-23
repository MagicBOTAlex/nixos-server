{ pkgs, lib, config, ... }:

let
  # Must match the server's targetIp
  nvmeServerIp = "192.168.50.10";
  port = "4420";

  # The exact same list of disks and UUIDs used on the server.
  # When NVMe block devices are shared, their filesystem UUIDs are preserved!
  disks = [
    { name = "disk1"; uuid = "964136a0-aac2-498d-8fda-b3f310026c26"; }
    { name = "disk2"; uuid = "fc16759c-24fc-46d6-99fe-865068605f46"; }
    { name = "disk3"; uuid = "8f2c41c0-84bb-40ee-a3f8-b1bbd378d5d7"; }
    { name = "disk4"; uuid = "b7318cf7-e467-40b4-b2bf-9675f128559b"; }
  ];

  # 1. Generate connection commands for each disk
  connectCommands = map
    (d: ''
      ${pkgs.nvme-cli}/bin/nvme connect \
        -t tcp \
        -a ${nvmeServerIp} \
        -s ${port} \
        -n "nqn.2026-07.org.nvmexpress:${d.name}" || true
    '')
    disks;

  # 2. Generate disconnection commands for graceful shutdown
  disconnectCommands = map
    (d: ''
      ${pkgs.nvme-cli}/bin/nvme disconnect \
        -n "nqn.2026-07.org.nvmexpress:${d.name}" || true
    '')
    disks;

  # 3. Mount fileSystems by UUID
  nvmeMounts = builtins.listToAttrs (map
    (d: {
      name = "/mnt/remote/${d.name}";
      value = {
        device = "/dev/disk/by-uuid/${d.uuid}";
        fsType = "ext4";
        options = [
          "defaults"
          "nofail"
          "_netdev"
          "x-systemd.requires=nvme-connect.service"
          "x-systemd.after=nvme-connect.service" # Ensure mounts happen strictly AFTER connect
        ];
      };
    })
    disks);

in
{
  boot.kernelModules = [ "nvme-tcp" ];

  systemd.services.nvme-connect = {
    description = "Connect to NVMe-oF Target Subsystems";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [ pkgs.nvme-cli ];

    script = pkgs.lib.concatStringsSep "\n" connectCommands;
    postStop = pkgs.lib.concatStringsSep "\n" disconnectCommands;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Note: Restart= directives removed to prevent oneshot conflicts
    };
  };

  fileSystems = nvmeMounts;

  environment.systemPackages = [ pkgs.nvme-cli ];
}
