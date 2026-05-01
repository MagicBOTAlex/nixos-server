{ config
, pkgs
, lib
, ...
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
    10.0.0.5 kube-snorre
    10.0.0.8 kube-metal
  '';
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

      extraOpts =
        let
          admissionConfig = pkgs.writeText "admission-config.yaml" ''
            apiVersion: apiserver.config.k8s.io/v1
            kind: AdmissionConfiguration
            plugins:
            - name: PodSecurity
              configuration:
                apiVersion: pod-security.admission.config.k8s.io/v1
                kind: PodSecurityConfiguration
                defaults:
                  enforce: "baseline"
                  enforce-version: "latest"
                exemptions:
                  namespaces: [ "kube-system" ]
          '';
          authConfig = pkgs.writeTextFile {
            name = "authentication-config.yaml";
            text = ''
              issuer:
                url: https://auth.deprived.dev/application/o/kubernetes-cluster/
                audiences: kubernetes-cluster
              claimMappings:
                username:
                  claim: email
                groups:
                  claim: groups
                  prefix: "oidc:"
            '';
          };
        in
        "--admission-control-config-file=${admissionConfig}";
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


  systemd.services."cert-provider" = {
    description = "serves the cert for control plane on wireguard interface";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 33333 --bind 10.0.0.2";

      # Restart settings
      Restart = "always";
      RestartSec = "5s";
      WorkingDirectory = "/var/lib/kubernetes/secrets";
    };
  };
}
