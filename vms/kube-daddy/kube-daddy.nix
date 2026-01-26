{ pkgs, ... }: {
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

    hashedPassword =
      "$6$HpwhjoEuhRZuFhJF$jEV3SxbcGKVlRRgbDx6YpySyTHKUIOnmUD0Rd4PLXsXhbnrgeBVCPfkK.cBCUmxUeQjNTzj4CDpP4XBxLz0EV0";

    shell = pkgs.fish;

  };

  environment.variables.EDITOR = "nvim";

  services.openssh = { enable = true; };
  imports = [ ./../../modules/getNvim.nix ./kubernetes.nix ];
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
    interfaces = [{
      type = "tap";
      id = "microvm-tap1"; # Matches the host's first tap
      mac = "02:00:00:00:00:01";
    }];

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
    shares = [{
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    }];

    # Writable disk allocation
    volumes = [{
      image = "/var/lib/microvms/kube-daddy/kube-daddy.img";
      mountPoint = "/";
      size = 32768; # Size in MB
    }];
  };

  networking = {
    hostName = "kube-daddy";
    useNetworkd = true;
    firewall.enable =
      false; # Keep disabled for easier testing, or allow port 22

    interfaces.enp0s4.ipv4.addresses = [{
      address = "10.0.0.2";
      prefixLength = 24;
    }];

    defaultGateway = {
      address = "10.0.0.1";
      interface = "enp0s4";
    };
    nameservers = [ "1.1.1.1" ];
  };

  # Allow passwordless root login for testing (Do not use in production!)
  services.getty.autologinUser = "root";
  users.users.root.password = "";

  systemd.network.enable = true;
  systemd.network.networks."11-microvm" = {
    matchConfig.Name = "vm-*";
    # Attach to the bridge that was configured above
    networkConfig.Bridge = "microvm";
  };

  system.stateVersion = "24.11";
}

