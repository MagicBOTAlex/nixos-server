{ config, pkgs, ... }:

{
  containers.static-server = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";

    # Dynamic host folder bind-mount
    bindMounts."/var/www/staticFiles" = {
      hostPath = "/path/to/your/static"; # your local folder on host
      isReadOnly = true;
    };

    # Forward port 6233 on the host into port 6233 in the container
    forwardPorts = [
      {
        from = 6233;
        to = 6233;
        protocol = "tcp";
      }
    ];

    # Inner container configuration
    config = { config, pkgs, ... }: {
      services.nginx = {
        enable = true;
        virtualHosts."localhost" = {
          listen = [ { addr = "0.0.0.0"; port = 6233; } ];
          locations."/staticFiles/" = {
            alias = "/var/www/staticFiles/";
            extraConfig = "autoindex on;";
          };
          locations."= /staticFiles" = {
            return = "301 /staticFiles/";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 6233 ];
      system.stateVersion = "24.05";
    };
  };
}
