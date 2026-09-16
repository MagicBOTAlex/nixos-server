{pkgs, ...}: {
    systemd.network.networks."10-direct-link" = {
    matchConfig.MACAddress = "00:e0:4c:68:00:6d";
    
    # Assign the local /32 IP
    address = [ "192.168.50.82/32" ];
    
    # Hijack the peer's /32 IP to route out of this specific link
    routes = [
      {
        routeConfig = {
          Destination = "192.168.50.59/32";
          Scope = "link";
        };
      }
    ];
    
    linkConfig = {
      ActivationPolicy = "always-up";
      RequiredForOnline = "no";
    };
  };
  }
