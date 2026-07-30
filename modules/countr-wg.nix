{ pkgs, ... }:

{
  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Open UDP port 51100
  networking.firewall.allowedUDPPorts = [ 51100 ];
  networking.nat = {
    enable = true;
    externalInterface = "enp8s0";
    internalInterfaces = [ "wg-countr" ];
  };

  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i wg-countr -o wg-countr -j ACCEPT
  '';

  networking.wireguard.interfaces = {
    # WireGuard configuration
    wg-countr = {
      ips = [ "198.222.0.1/24" ];
      listenPort = 51100;

      # Load the key dynamically from file at runtime
      privateKeyFile = "/wireguard/server_private.key";


      peers = [
        {
          # countr
          publicKey = "fqx8ZDgNxgkd1uAQQzCkYJZPvZiGVsNZa3TwGk4fiQw=";
          allowedIPs = [ "198.222.0.2/32" ];
        }
        {
          # BOTAndroid
          publicKey = "8D8OdmzOvhRRR72hiVUaLKzAC0GxJE5tC/T2GIXDtTo=";
          allowedIPs = [ "198.222.0.3/32" ];
        }
        {
          # Desk
          publicKey = "4NyKWZrATqdLua/M70C20QfOafvxKgRAW1innXPZ7kE=";
          allowedIPs = [ "198.222.0.4/32" ];
        }
      ];
    };
  };
}
