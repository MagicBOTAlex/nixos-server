{ pkgs, ... }:

{
  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Open UDP port 51100
  networking.firewall.allowedUDPPorts = [ 51100 ];

  # WireGuard configuration
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51100;

      # Load the key dynamically from file at runtime
      privateKeyFile = "/wireguard/private.key";

      peers = [
        {
          # Client's public key
          publicKey = "smhjztUH9NA+Nal+YHrmDQVgOtN01EPhASvgPlkQmRc=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
