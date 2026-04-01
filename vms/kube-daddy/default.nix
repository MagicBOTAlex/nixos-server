{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ virtiofsd ];
  microvm.autostart = [ "kube-daddy" ];
  microvm.vms."kube-daddy" = {
    config = ./kube-daddy.nix;
  };

  systemd.services.kube-iptable = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iptables}/bin/iptables -t nat -I POSTROUTING 1 -s 10.0.0.0/24 -o enp8s0 -j MASQUERADE ";
      RemainAfterExit = true;
      User = "root";
    };

    stopIfChanged = true;
  };

  networking = {
    bridges = {
      "br0" = {
        interfaces = [
          "microvm-tap1"
          "microvm-tap2"
        ];
      };
    };

    interfaces.br0.ipv4.addresses = [
      {
        address = "10.0.0.1";
        prefixLength = 24;
      }
    ];

    localCommands = ''
      ip tuntap add dev microvm-tap1 mode tap user root || true
      ip tuntap add dev microvm-tap2 mode tap user root || true
      ip link set microvm-tap1 up
      ip link set microvm-tap2 up
    '';

    nat = {
      enable = true;
      externalInterface = "enp8s0";
      internalIPs = [ "10.0.0.0/24" ];
      forwardPorts = [
        {
          sourcePort = 8877;
          destination = "10.0.0.2:8888";
          proto = "tcp";
        }
        # { # Access this directly from host by 10.0.0.2:4325
        #   sourcePort = 4325; # argocd
        #   destination = "10.0.0.2:8080";
        #   proto = "tcp";
        # }
        {
          sourcePort = 6443;
          destination = "10.0.0.2:6443";
          proto = "tcp";
        }
        {
          sourcePort = 4123;
          destination = "10.0.0.2:4123";
          proto = "tcp";
        }
        {
          sourcePort = 8472;
          destination = "10.0.0.2:8472";
          proto = "udp";
        }
        {
          sourcePort = 2379;
          destination = "10.0.0.2:2379";
          proto = "udp";
        }
        {
          sourcePort = 2380;
          destination = "10.0.0.2:2380";
          proto = "udp";
        }
        {
          sourcePort = 2379;
          proto = "tcp";
          destination = "10.0.0.2:2379";
        }
        {
          sourcePort = 2380;
          destination = "10.0.0.2:2380";
          proto = "tcp";
        }
        {
          sourcePort = 4001;
          destination = "10.0.0.2:4001";
          proto = "udp";
        }
        {
          sourcePort = 4001;
          destination = "10.0.0.2:4001";
          proto = "tcp";
        }
        # If your app uses UDP (like HTTP/3 or QUIC), add this too:
        # { sourcePort = 8888; destination = "10.0.0.2:8888"; proto = "udp"; }
      ];
    };

    # 5. Update Firewall to trust the Bridge
    firewall.trustedInterfaces = [ "br0" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/microvms/shared 0755 microvm kvm -"
    "d /var/lib/microvms/shared/kube 0755 microvm kvm -"
    "d /var/lib/microvms/shared/docking 0755 microvm kvm -"
    "d /var/lib/microvms/shared/.config 0755 microvm kvm -"
    "d /var/lib/microvms/shared/.local 0755 microvm kvm -"
  ];
}
