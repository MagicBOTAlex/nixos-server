{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ virtiofsd ];
  microvm.autostart = [ "kube-daddy" ];
  microvm.vms."kube-daddy" = {
    config = ./kube-daddy.nix;
  };

}
