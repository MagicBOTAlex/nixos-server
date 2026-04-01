{ pkgs, ... }:
{
  fileSystems."/export/mafuyu" = {
    device = "/kube-store";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.0.0.0/42(rw,fsid=0,no_subtree_check) 
  '';
}
