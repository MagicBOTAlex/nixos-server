{ pkgs, ... }: {
  # services.caddy = { enable = true; };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "zhen@deprived.dev";
  networking.firewall.enable = true;

  networking.useNetworkd = true;
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."10-enp8s0" = {
    matchConfig.Name = "enp8s0";
    networkConfig.DHCP = "ipv4";
    dhcpV4Config.UseRoutes = true;
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 2;
    "net.ipv6.conf.default.accept_ra" = 2;
  };

  networking.firewall = {

      trustedInterfaces = [ "wpan0" ];
    };

services.avahi = {
   enable = true;
   nssmdns4 = true;  # Allows hostname resolution via mDNS (IPv4)
   nssmdns6 = true;  # Allows hostname resolution via mDNS (IPv6)
   openFirewall = true; # Automatically opens UDP port 5353
 };
}
