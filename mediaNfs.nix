{ pkgs, ... }:

let
  nfsServerIp = "192.168.50.59";
  diskShares = [ "disk1" "disk2" "disk3" "disk4" ];

  nfsMounts = builtins.listToAttrs (map
    (share: {
      name = "/mnt/remote/${share}";
      value = {
        # Points directly to the server's mounted disk path
        device = "${nfsServerIp}:/mnt/${share}";
        fsType = "nfs";
        options = [
          "nfsvers=4.2"
          "nofail"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
          "x-systemd.requires=network-online.target"
          "_netdev"
          "noatime"
        ];
      };
    })
    diskShares);

in
{
  boot.supportedFilesystems = [ "nfs" ];
  
  # Note: rpcbind is optional for NFSv4-only setups, but good practice to leave on.
  services.rpcbind.enable = true;

  fileSystems = nfsMounts;
}
