{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ virtiofsd ];
  microvm.autostart = [ "kube-vm2" ];
  microvm.vms."kube-vm2" = { config = ./kube-vm.nix; };

}
