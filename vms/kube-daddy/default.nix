{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ virtiofsd ];
  microvm.autostart = [ "kube-daddy" ];
  microvm.vms."kube-daddy" = { config = ./kube-daddy.nix; };

  networking = {
    # 1. Create a Bridge (The Switch)
    bridges = { "br0" = { interfaces = [ "microvm-tap1" "microvm-tap2" ]; }; };

    # 2. Assign the Gateway IP to the Bridge (NOT the taps)
    interfaces.br0.ipv4.addresses = [{
      address = "10.0.0.1";
      prefixLength = 24;
    }];

    # 3. Create persistent TAP interfaces so they exist at boot
    #    (This requires you to create a systemd service or use ip tuntap commands. 
    #     Below is a "hack" using a dummy script, or use systemd-networkd netdevs if enabled)
    #     The cleanest NixOS way without networkd is often just letting the bridge create them 
    #     or defining them as virtual devices (requires manual script usually).
    #     
    #     Use this script to ensure they exist before the bridge tries to enslave them:
    localCommands = ''
      ip tuntap add dev microvm-tap1 mode tap user root || true
      ip tuntap add dev microvm-tap2 mode tap user root || true
      ip link set microvm-tap1 up
      ip link set microvm-tap2 up
    '';

    # 4. Update NAT to use the Bridge
    nat = {
      enable = true;
      externalInterface = "enp8s0"; # Your physical interface
      internalInterfaces = [ "br0" ]; # NAT traffic coming from the bridge

      forwardPorts = [
        {
          sourcePort = 8877;
          destination = "10.0.0.2:8888";
          proto = "tcp";
        }
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
        # If your app uses UDP (like HTTP/3 or QUIC), add this too:
        # { sourcePort = 8888; destination = "10.0.0.2:8888"; proto = "udp"; }
      ];
    };

    # 5. Update Firewall to trust the Bridge
    firewall.trustedInterfaces = [ "br0" ];
  };
}
