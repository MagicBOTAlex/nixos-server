{pkgs, ... } : {
  imports = [
    ./networkSetup.nix
  ];

  services.caddy.virtualHosts."immich.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:2283
    '';
  };


  services.caddy.virtualHosts."ha.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:8123
    '';
  };

  services.caddy.virtualHosts."jelly.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:8096
    '';
  };


  services.caddy.virtualHosts."pocket.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:5500
    '';
  };

  services.caddy.virtualHosts."seer.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:5055
    '';
  };

  services.caddy.virtualHosts."development.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:5550
    '';
  };

services.caddy.virtualHosts."spotify.api.deprived.dev" = {
  extraConfig = ''
    encode zstd gzip

    # --- CORS: preflight (OPTIONS) ---
    @preflight {
      method OPTIONS
      header Origin *
      header Access-Control-Request-Method *
    }
    handle @preflight {
      header {
        Access-Control-Allow-Origin "{http.request.header.Origin}"
        Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        Access-Control-Allow-Headers "{http.request.header.Access-Control-Request-Headers}"
        Access-Control-Allow-Credentials "true"
        Access-Control-Max-Age "600"
        Vary "Origin"
      }
      respond 204
    }

    # --- Auth: protect everything except OPTIONS ---
    @protected {
      not method OPTIONS
    }
    basicauth @protected {
      alice $2a$14$GbqQnETcOz5fNEbS06Y0E.HxRIIgPKAK7OMijT1Bv63h3V6S/gwRG
    }

    # --- Reverse proxy: strip upstream CORS so we don't end up with duplicates ---
    reverse_proxy 127.0.0.1:6666 {
      header_down -Access-Control-Allow-Origin
      header_down -Access-Control-Allow-Methods
      header_down -Access-Control-Allow-Headers
      header_down -Access-Control-Allow-Credentials
      header_down -Vary
    }

    # --- CORS: set headers on actual responses (only when Origin is present) ---
    @cors header Origin *
    header @cors {
      Access-Control-Allow-Origin "{http.request.header.Origin}"
      Access-Control-Allow-Credentials "true"
      # Optionally expose any headers your frontend needs to read:
      # Access-Control-Expose-Headers "Content-Type, Content-Length, Date"
      Vary "Origin"
    }
  '';
};


services.caddy.virtualHosts."spotify.playing.deprived.dev" = {
  extraConfig = ''
    encode zstd gzip

    @preflight method OPTIONS
    handle @preflight {
      header {
        Access-Control-Allow-Origin "{http.request.header.Origin}"
        Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        Access-Control-Allow-Headers "{http.request.header.Access-Control-Request-Headers}"
        Access-Control-Allow-Credentials "true"
        Access-Control-Max-Age "600"
        Vary "Origin"
      }
      respond 204
    }

    @protected not method OPTIONS
    basicauth @protected {
      alice $2a$14$GbqQnETcOz5fNEbS06Y0E.HxRIIgPKAK7OMijT1Bv63h3V6S/gwRG
    }

    reverse_proxy 127.0.0.1:8800

    header {
      Access-Control-Allow-Origin "{http.request.header.Origin}"
      Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS"
      Access-Control-Allow-Headers "{http.request.header.Access-Control-Request-Headers}"
      Access-Control-Allow-Credentials "true"
      Vary "Origin"
    }
  '';
};

  services.caddy.virtualHosts."lyrics.deprived.dev" = {
    extraConfig = ''
        reverse_proxy * 127.0.0.1:7444
    ''; 
  };
}
