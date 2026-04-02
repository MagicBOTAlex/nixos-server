{
  config,
  pkgs,
  lib,
  ...
}:
let
  # When using easyCerts=true the IP Address must resolve to the master on creation.
  # So use simply 127.0.0.1 in that case. Otherwise you will have errors like this https://github.com/NixOS/nixpkgs/issues/59364
  kubeMasterIP = "176.23.63.215";
  kubeMasterHostname = "clussy.deprived.dev";
  kubeMasterAPIServerPort = 6443;
in
{
  # resolve master hostname
  networking.extraHosts = ''
    ${kubeMasterIP} ${kubeMasterHostname}
    10.0.0.2 kube-daddy
    10.0.0.4 kube-desk
    10.0.0.5 kube-snorre'';
  networking.firewall.enable = false;

  imports = [
    ./argo-forward.nix
    ./jelly-forward.nix
    ./longhorn-deps.nix
  ];

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    (pkgs.callPackage /etc/nixos/modules/customPackages/wgmesh { })
  ];

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    flannel.enable = true;

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false --resolv-conf=/run/systemd/resolve/resolv.conf";
  };

  services.flannel = {
    iface = "br0";
    publicIp = "10.0.0.2";
  };
}
