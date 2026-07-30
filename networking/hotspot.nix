{ config, pkgs, ... }:

{
  # 1. Enable systemd-networkd
  networking.useNetworkd = true;

  # 2. Hostapd configuration for 5GHz Access Point
  services.hostapd = {
    enable = true;
    radios.wlp7s0 = {
      # Change band to 5GHz
      band = "5g";
      
      # Select a valid 5GHz channel (36, 40, 44, 48 are standard indoor non-DFS channels)
      channel = 36;
      
      # Required for 5GHz operation to comply with local power/frequency rules
      countryCode = "US"; # <-- Change to your two-letter country code

      networks.wlp7s0 = {
        ssid = "MyIsolated5GHotspot";
        
        # WPA2-Personal security
        authentication = {
          mode = "wpa2-sha1";
          wpaPassword = "YourStrongPasswordHere";
        };
      };
    };
  };

  # 3. Networkd configuration for isolated IP & local DHCP
  systemd.network.networks."10-wlp7s0" = {
    matchConfig.Name = "wlp7s0";
    
    # Assign static address for the server on this isolated subnet
    address = [ "10.50.0.1/24" ];
    
    # Enable built-in networkd DHCP server for connected clients
    networkConfig = {
      DHCPServer = true;
      IPv6SendRA = false;
    };

    # Configure DHCP server to NOT advertise internet access (no default gateway or DNS)
    dhcpServerConfig = {
      PoolOffset = 10;
      PoolSize = 50;
      EmitRouter = false; # Prevents clients from routing traffic through this interface
      EmitDNS = false;
    };
  };

  # 4. Strictly disable IP forwarding globally across the system
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 0;
    "net.ipv6.conf.all.forwarding" = 0;
  };
}
