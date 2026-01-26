{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    containerd
  ];

  virtualisation = {
    docker.enable = true;
    containerd.enable = true;
  };

  services = {
    etcd = {
      enable = true;
      peerCertFile = "/etc/kubernetes/pki/etcd/peer.crt";
      peerKeyFile = "/etc/kubernetes/pki/etcd/peer.key";
      peerTrustedCaFile = "/etc/kubernetes/pki/etcd/ca.crt";
      peerClientCertAuth = true;

      certFile = "/etc/kubernetes/pki/etcd/server.crt";
      keyFile = "/etc/kubernetes/pki/etcd/server.key";
      trustedCaFile = "/etc/kubernetes/pki/etcd/ca.crt";
    };
  };

  services.kubernetes = {
    masterAddress = "10.0.2.15"; # From "ip addr"  and choosing enp0s4:
    kubelet.enable = true;

    apiserver = {
      enable = true;
      advertiseAddress = "10.0.2.15"; # From your logs
      bindAddress = "0.0.0.0";
      securePort = 6443;

      # 1. Etcd Connectivity (Fixes "unknown authority" & "remote error: tls: certificate required")
      etcd = {
        servers = [ "https://10.0.2.15:2379" ];
        caFile = "/etc/kubernetes/pki/etcd/ca.crt"; # MUST be Etcd CA [cite: 60]
        certFile = "/etc/kubernetes/pki/apiserver-etcd-client.crt"; # [cite: 59]
        keyFile = "/etc/kubernetes/pki/apiserver-etcd-client.key"; # [cite: 59]
      };

      # 2. Service Account Signing (Fixes "invalid RSA key")
      serviceAccountIssuer = "https://kubernetes.default.svc"; # [cite: 108]
      serviceAccountSigningKeyFile =
        "/etc/kubernetes/pki/sa.key"; # Private Key [cite: 110]
      serviceAccountKeyFile =
        "/etc/kubernetes/pki/sa.pub"; # Public Key [cite: 112]

      # 3. Serving TLS (Fixes Scheduler "certificate signed by unknown authority")
      tlsCertFile =
        "/etc/kubernetes/pki/apiserver.crt"; # Server Identity [cite: 116]
      tlsKeyFile = "/etc/kubernetes/pki/apiserver.key"; # [cite: 117]
      clientCaFile =
        "/etc/kubernetes/pki/ca.crt"; # Trust Client Certs (Scheduler) [cite: 76]

      # 4. Kubelet Communication (Best Practice)
      kubeletClientCaFile = "/etc/kubernetes/pki/ca.crt"; # [cite: 94]
      kubeletClientCertFile =
        "/etc/kubernetes/pki/apiserver-kubelet-client.crt"; # [cite: 96]
      kubeletClientKeyFile =
        "/etc/kubernetes/pki/apiserver-kubelet-client.key"; # [cite: 98]
    };

    scheduler = {
      enable = true;
      address = "0.0.0.0"; # Listen on all interfaces
      leaderElect = true;

      # Maps to --kubeconfig
      kubeconfig = {
        server = "https://10.0.2.15:6443";
        caFile = "/etc/kubernetes/pki/ca.crt";
        certFile = "/etc/kubernetes/pki/scheduler.crt"; # Client Cert
        keyFile = "/etc/kubernetes/pki/scheduler.key";
      };
    };

    controllerManager = {
      enable = true;
      bindAddress = "0.0.0.0"; # Listen on all interfaces
      leaderElect = true;

      # 1. Signing Service Accounts (MUST match API Server sa.key)
      serviceAccountKeyFile = "/etc/kubernetes/pki/sa.key";

      # 2. CA included in Service Account secrets
      rootCaFile = "/etc/kubernetes/pki/ca.crt";

      # 3. Kubeconfig for talking to API Server
      kubeconfig = {
        server = "https://10.0.2.15:6443";
        caFile = "/etc/kubernetes/pki/ca.crt";
        certFile = "/etc/kubernetes/pki/controller-manager.crt"; # Client Cert
        keyFile = "/etc/kubernetes/pki/controller-manager.key";
      };

      # 4. HTTPS Serving Certs (for metrics/health)
      tlsCertFile =
        "/etc/kubernetes/pki/controller-manager.crt"; # Reusing client cert is fine here
      tlsKeyFile = "/etc/kubernetes/pki/controller-manager.key";
    };
  };
}

