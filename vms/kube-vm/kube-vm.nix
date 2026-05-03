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

    shell = pkgs.fish;

  };

  programs.fish = { enable = true; };
  documentation.man.generateCaches = false;

  services.openssh = { enable = true; };
  imports = [ ./../../modules/getNvim.nix ./kubernetes/kubernetes.nix ];
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
    dig
    argocd
  ];

  # --- MicroVM Specific Settings ---
  microvm = {
    # Choose your hypervisor: "qemu", "firecracker", "cloud-hypervisor", etc.
    hypervisor = "qemu";

    # Create a tap interface or user networking
    interfaces = [{
      type = "tap";
      id = "microvm-tap2"; # Matches the host's second tap
      mac = "02:00:00:00:00:02";
    }];

    # Mount the host's /nix/store explicitly (read-only)
    # This makes the VM start instantly as it shares the host store.
    shares = [{
      tag = "ro-store";
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
    }];

    # Writable disk allocation
    volumes = [{
      image = "/var/lib/microvms/kube-vm/kube-vm.img";
      mountPoint = "/";
      size = 512 * 4; # Size in MB
    }];
  };

  boot.kernelModules = [ "br_netfilter" ];

  networking = {
    hostName = "kube-vm";
    useNetworkd = true;
    firewall.enable = false;

    # 1. Define the interface explicitly
    interfaces.enp0s4.ipv4.addresses = [{
      address = "10.0.0.3";
      prefixLength = 24;
    }];

    # 2. Fix: Specify both address AND interface for the gateway
    defaultGateway = {
      address = "10.0.0.1";
      interface = "enp0s4";
    };

    nameservers = [ "1.1.1.1" "8.8.8.8" ];
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
