{ config, ... }:

{
  networking.wg-quick.interfaces = {
    wg0 = {
      # The local IP address for this interface
      address = [ "10.13.13.3/32" ];

      # The DNS server to use when the tunnel is active
      dns = [ "10.0.101.1" ];

      # The port to listen on
      listenPort = 51820;

      # Path to the private key file (using age for security)
      privateKeyFile = "/root/wg/priv.key";

      peers = [
        {
          # The public key of the remote peer
          publicKey = "QD36zS9c4IWYzqPAjP88hX9nx4wWJ9thB9YlO6vCtzo=";

          # Path to the preshared key file (security best practice)
          presharedKeyFile = "/root/wg/pre.key";

          # The remote endpoint and port
          endpoint = "37.49.130.171:51820";

          # Traffic to route through the tunnel (0.0.0.0/0 sends everything)
          allowedIPs = [ "0.0.0.0/0" ];
        }
      ];
    };
  };
}
