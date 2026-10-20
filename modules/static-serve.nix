{ config, pkgs, ... }:

{
  containers.static-server = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";

    bindMounts."/var/www/staticFiles" = {
      hostPath = "/staticFiles/"; # adjust to your host static directory
      isReadOnly = true;
    };

    forwardPorts = [
      {
        hostPort = 6233;
        containerPort = 6233;
        protocol = "tcp";
      }
    ];

    config = { config, pkgs, ... }: {
      services.nginx = {
        enable = true;
        virtualHosts."default" = {
          default = true; # Catch all requests arriving on this port
          listen = [ { addr = "0.0.0.0"; port = 6233; } ];
          
          locations."/" = {
            alias = "/var/www/staticFiles/";
            extraConfig = ''
              autoindex on;
              autoindex_exact_size off;
              autoindex_localtime on;
            '';
          };

          # locations."= /staticFiles" = {
          #   return = "301 /staticFiles/";
          # };
          #
          # # Optional: redirect root / to /staticFiles/
          # locations."= /" = {
          #   return = "302 /staticFiles/";
          # };
        };
      };

      networking.firewall.allowedTCPPorts = [ 6233 ];
      system.stateVersion = "24.05";
    };
  };
}
