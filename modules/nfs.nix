{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ kubernetes-helm ];

  fileSystems."/export" = {
    device = "/kube-store";
    options = [ "bind" ];
    fsType = "none";
  };

  networking.firewall.allowedTCPPorts = [111 2049 4045 1110];
  networking.firewall.allowedUDPPorts = [111 2049 4045 1110];

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.0.0.0/24(rw,fsid=0,no_subtree_check,crossmnt,no_root_squash)
  '';
}
