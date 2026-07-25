{ config, pkgs, ... }:

{
  # Enable and configure Dnsmasq using the nixos module interface
  services.dnsmasq = {
    enable = true;

    settings = {
      # Keep local domain queries within the local DNS
      local = "/deprived.dev/";
      domain = "deprived.dev";

      # Map subdomains to the designated IP address
      address = [
        "/sonarr.deprived.dev/192.168.50.82"
        "/radarr.deprived.dev/192.168.50.82"
        "/prowlarr.deprived.dev/192.168.50.82"
        "/qbit.deprived.dev/192.168.50.82"
      ];

      # Upstream DNS servers for internet queries (uses services.dnsmasq.settings.server)
      server = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      # Bind interfaces properly for incoming DNS requests
      bind-interfaces = true;
    };
  };

  # Open port 53 (UDP/TCP) in the firewall to accept queries from other devices
  networking.firewall = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
