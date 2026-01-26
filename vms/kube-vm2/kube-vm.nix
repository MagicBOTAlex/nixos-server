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
    dig
  ];

  # --- MicroVM Specific Settings ---
  microvm = {
    # Choose your hypervisor: "qemu", "firecracker", "cloud-hypervisor", etc.
    hypervisor = "qemu";

    # Create a tap interface or user networking
    interfaces = [{
      type = "user"; # 'user' networking is easiest for testing (slirp)
      id = "eth0";
      mac = "02:00:00:00:00:01";
    }];

    forwardPorts = [{
      from = "host";
      host.port = 2223;
      guest.port = 22;
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
      image = "/var/lib/microvms/kube-vm2/kube-vm2.img";
      mountPoint = "/";
      size = 512 * 4; # Size in MB
    }];
  };

  system.stateVersion = "24.11";
}
