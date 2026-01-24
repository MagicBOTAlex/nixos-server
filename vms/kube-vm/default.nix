{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ virtiofsd ];
  microvm.autostart = [ "kube-vm" ];
  microvm.vms."kube-vm" = { config = ./kube-vm.nix; };

}
