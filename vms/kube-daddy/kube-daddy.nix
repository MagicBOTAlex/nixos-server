{ lib, pkgs, ... }:

{
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhiPhFbCi64NduuV794omgS8mctBLXtqxbaEJyUo6lg botalex@DESKTOPSKTOP-ENDVV0V"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFhTExbc9m4dCK6676wGiA8zPjE0l/9Fz2yf0IKvUvg snorre@archlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxUPAsPkri0B+xkO3sCHJZfKgAbgPcepP8J4WW4yyLj u0_a167@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfQLOKUnOARUAs8X1EL1GRHoCQ0oMun0vzL7Z78yOsM nixos@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw1ckvXz78ITeqANrWSkJl6PJo2AMA4myNrRMBAB7xW zhentao2004@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhcUZbIMX0W27l/FMF5WijpdsJAK329/P008OEAfcyz botmain@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILB0esg3ABIcYWxvQKlPuwEE6cbhNcWjisfky0wnGirJ root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxUPAsPkri0B+xkO3sCHJZfKgAbgPcepP8J4WW4yyLj u0_a167@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyZOZlcQBmqSPxjaGgE2tP+K7LYziqjFUo3EX12rGtf botlap@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLSUXsao6rjC3FDtRHhh7z6wqMtA/mqL50e1Dj9a2wE botserver@botserver"
    ];

    hashedPassword = "$6$HpwhjoEuhRZuFhJF$jEV3SxbcGKVlRRgbDx6YpySyTHKUIOnmUD0Rd4PLXsXhbnrgeBVCPfkK.cBCUmxUeQjNTzj4CDpP4XBxLz0EV0";

    shell = pkgs.fish;

  };

  environment.variables.EDITOR = "nvim";

  services.openssh = {
    enable = true;
  };
  imports = [
    ./../../modules/getNvim.nix
    ./kubernetes.nix
    # ./wg-snorre.nix
  ];
  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    curl
    busybox
    gcc
    tree-sitter
    busybox
    nodejs_22
    screen
    fastfetch
    btop
    openssh
    ripgrep
    openssl
    dig
    argocd
    gnutar
    wireguard-tools
    python312
  ];

  programs.fish = {
    enable = true;

  };
  documentation.man.generateCaches = false;

  # --- MicroVM Specific Settings ---
  microvm = {
    # Choose your hypervisor: "qemu", "firecracker", "cloud-hypervisor", etc.
    hypervisor = "qemu";

    mem = 8192;
    vcpu = 8;

    # Create a tap interface or user networking
    interfaces = [
      {
        type = "tap";
        id = "microvm-tap1"; # Matches the host's first tap
        mac = "02:00:00:00:00:01";
      }
    ];

    # forwardPorts = [
    #   {
    #     from = "host";
    #     host.port = 22222;
    #     guest.port = 22;
    #   }
    #   {
    #     from = "host";
    #     host.port = 6443; # Port you will access on your machine
    #     guest.port = 6443; # Port the service is listening on inside the VM
    #   }
    #   {
    #     from = "host";
    #     host.port = 8877; # certmgr
    #     guest.port = 8888;
    #   }
    #   {
    #     from = "host";
    #     host.port = 4325; # argocd
    #     guest.port = 4325;
    #   }
    #
    # ];

    # Mount the host's /nix/store explicitly (read-only)
    # This makes the VM start instantly as it shares the host store.
    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
      {
        proto = "9p";
        tag = "docking-mount";
        # Source path can be absolute or relative
        # to /var/lib/microvms/$hostName
        source = "../shared/docking";
        mountPoint = "/root/docking";
      }
      {
        proto = "9p";
        tag = "kube-wireguard";
        # Source path can be absolute or relative
        # to /var/lib/microvms/$hostName
        source = "../shared/wg";
        mountPoint = "/root/wg";
      }
      # {
      #   proto = "9p";
      #   tag = "kube-mount";
      #   source = "../shared/kube";
      #   mountPoint = "/var/lib/kubernetes";
      # }
      # {
      #   proto = "9p";
      #   tag = "config";
      #   source = "../shared/.config";
      #   mountPoint = "/root/.config";
      # }
      # {
      #   proto = "9p";
      #   tag = "local";
      #   source = "../shared/.local";
      #   mountPoint = "/root/.local";
      # }
    ];

    # Writable disk allocation
    volumes = [
      {
        image = "/var/lib/microvms/kube-daddy/kube-daddy.img";
        mountPoint = "/";
        size = 32768; # Size in MB
      }
    ];
  };

  services.resolved.enable = true;
  networking = {
    hostName = "kube-daddy";
    useNetworkd = true;
    firewall.enable = false;
    nameservers = [
      "10.0.0.1"
      "8.8.8.8"
    ];
  };

  systemd.network = {
    # 1. Define the Bridge Device
    netdevs."20-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br0";
      };
    };

    networks = {
      # 2. Configure the Bridge (IP & Gateway go here now)
      "30-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          Address = "10.0.0.2/24";
          Gateway = "10.0.0.1";
          DNS = [
            "10.0.0.1"
            "8.8.8.8"
          ];
        };
        linkConfig.RequiredForOnline = "routable";
      };

      # 3. Catch the changing interface and attach it to the bridge
      "40-uplink" = {
        # This wildcard matches enp0s7, enp1s0, etc.
        matchConfig.Name = "en*";
        networkConfig.Bridge = "br0";
      };
    };
  };

  # Allow passwordless root login for testing (Do not use in production!)
  services.getty.autologinUser = "root";
  users.users.root.password = "";

  systemd.services."load-br_netfilter" = {
    enable = true;
    description = "Modprobe br_netfilter";
    before = [ "flannel.service" ];
    wantedBy = [
      "multi-user.target"
      "flannel.service"
    ];

    script = ''
      ${pkgs.kmod}/bin/modprobe br_netfilter
    '';
  };

  systemd.network.enable = true;
  systemd.network.networks."11-microvm" = {
    matchConfig.Name = "vm-*";
    # Attach to the bridge that was configured above
    networkConfig.Bridge = "microvm";
  };

  system.stateVersion = "24.11";

  systemd.tmpfiles.rules = [
    "d  /root/.kube       0755  root  root  -"
    "d  /root/.config       0755  root  root  -"
    "d  /root/.local       0755  root  root  -"
    "L+ /root/.kube/config -     -     -      -    /etc/kubernetes/cluster-admin.kubeconfig"
  ];
}
