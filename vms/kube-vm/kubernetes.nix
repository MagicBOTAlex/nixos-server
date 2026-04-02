{ config, pkgs, ... }:
let
  kubeMasterIP = "176.23.63.215";
  kubeMasterHostname = "clussy.deprived.dev";
  kubeMasterAPIServerPort = 6443;
in
{
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";
  networking.firewall.enable = false;

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    kubernetes-helm
  ];

  services.kubernetes =
    let
      api = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    in
    {
      roles = [ "node" ];
      masterAddress = kubeMasterHostname;
      easyCerts = true;

      # point kubelet and other services to kube-apiserver
      kubelet.kubeconfig.server = api;
      apiserverAddress = api;

      # use coredns
      addons.dns.enable = true;
      flannel.enable = true;

      # needed if you use swap
      kubelet.extraOpts = "--fail-swap-on=false";
    };
}
