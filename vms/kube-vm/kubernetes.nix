{ pkgs, ... }:
let
  kubeMasterIP = "37.49.130.171";
  kubeMasterHostname = "polycule.deprived";
  kubeMasterAPIServerPort = 6443;
in {
  nixpkgs.overlays = [
    (final: prev: {
      containerd = prev.containerd.overrideAttrs rec {
        version = "1.7.29";

        src = final.fetchFromGitHub {
          owner = "containerd";
          repo = "containerd";
          rev = "v${version}";
          sha256 = "sha256-aR0i+0v2t6vyI+QN30P1+t+pHU2Bw7/XPUYLjJm1rhw=";
        };

        installTargets = [ "install" ];
        outputs = [ "out" ];
      };
    })
  ];

  virtualisation.containerd.enable = true;
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    argocd
    openiscsi
    nfs-utils
  ];

  networking.useNetworkd = true;
  networking.extraHosts = ''
    ${kubeMasterIP} ${kubeMasterHostname} 
      192.168.50.82  botkube'';
  services.kubernetes = let
    api = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
  in {
    roles = [ "node" ];
    masterAddress = kubeMasterHostname;
    easyCerts = true;
    apiserver.allowPrivileged = true;

    # point kubelet and other services to kube-apiserver
    kubelet.kubeconfig.server = api;
    apiserverAddress = api;

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts =
      "--fail-swap-on=false --resolv-conf=/run/systemd/resolve/resolv.conf";
  };

  systemd.services."forward-argocd" = {
    enable = true;
    description =
      "forwards argocd running on kubernetes to argocd.spoodythe.one";
    after = [ "network-online.target" "kubelet.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      ${pkgs.kubernetes}/bin/kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 4325:80 
    '';
    serviceConfig = { User = "botserver"; };
  };
}
