{pkgs, ... } : { 
  services.caddy.enable = true;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "zhen@deprived.dev";
  networking.firewall.enable = false;

}
