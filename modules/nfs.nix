{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 111 2049 4045 1110 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4045 1110 ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /downloads 192.168.50.0/24(rw,sync,no_subtree_check,no_root_squash,insecure,crossmnt)
    '';
  };
}
