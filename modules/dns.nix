{ config, pkgs, ... }:

{
  # Enable and configure Dnsmasq using the nixos module interface
  services.dnsmasq = {
    enable = true;

    settings = {
      # Keep local domain queries within the local DNS
      local = "/deprived.internal/";
      domain = "deprived.internal";

      listen-address = [
        "127.0.0.1"
        "192.168.50.82"
      ];

      # Use bind-dynamic instead of bind-interfaces to prevent startup race conditions
      bind-dynamic = true;

      # Map subdomains to the designated IP address
      address = [
        "/sonarr.deprived.internal/192.168.50.82"
        "/radarr.deprived.internal/192.168.50.82"
        "/prowlarr.deprived.internal/192.168.50.82"
        "/qbit.deprived.internal/192.168.50.82"
      ];

      # Upstream DNS servers for internet queries
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };

  # Open port 53 (UDP/TCP) in the firewall to accept queries from other devices
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
