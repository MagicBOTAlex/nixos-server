{ pkgs, ... }: {
  imports = [ ./networkSetup.nix ];

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

  services.caddy.virtualHosts."seer.deprived.dev" = {
    extraConfig = ''
      reverse_proxy * 127.0.0.1:5055
    '';
  };

  services.caddy.virtualHosts."penpot.deprived.dev" = {
    extraConfig = ''
      reverse_proxy * 127.0.0.1:5544
    '';
  };

  services.caddy.virtualHosts."api.deprived.dev" = {
    extraConfig = ''
      reverse_proxy * 127.0.0.1:6333
    '';
  };

  services.caddy.virtualHosts."pocket.deprived.dev" = {
    extraConfig = ''
      # Match allowed origins
      @allowedOrigin header_regexp Origin ^https?://(localhost(:[0-9]+)?|deprived\.dev|([a-z0-9-]+\.)*deprived\.dev)$
      @preflight method OPTIONS

      # Preflight: answer directly
      handle @preflight {
        header {
          -Access-Control-Allow-Origin
          -Access-Control-Allow-Methods
          -Access-Control-Allow-Headers
          -Access-Control-Allow-Credentials
          -Vary
        }
        header @allowedOrigin {
          Access-Control-Allow-Origin "{http.request.header.Origin}"
          Access-Control-Allow-Methods "GET,POST,PUT,PATCH,DELETE,OPTIONS"
          Access-Control-Allow-Headers "*"
          Access-Control-Allow-Credentials "true"
          Vary "Origin"
        }
        respond 204
      }

      # Actual requests: proxy, strip upstream CORS, then set ours
      handle {
        reverse_proxy 127.0.0.1:3433 {
          header_down -Access-Control-Allow-Origin
          header_down -Access-Control-Allow-Methods
          header_down -Access-Control-Allow-Headers
          header_down -Access-Control-Allow-Credentials
          header_down -Vary
        }
        header @allowedOrigin {
          Access-Control-Allow-Origin "{http.request.header.Origin}"
          Access-Control-Allow-Credentials "true"
          Vary "Origin"
        }
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

  services.caddy.virtualHosts."zhenss.deprived.dev" = {
    extraConfig = ''
      reverse_proxy * 127.0.0.1:8388
    '';
  };

  services.caddy.virtualHosts."direct.stream.deprived.dev" = {
    extraConfig = ''
      @allowKey {
        query key=0c156f3d-dc1d-489f-866e-69e306249e92
      }

      route {
        handle @allowKey {
          reverse_proxy http://127.0.0.1:3344
        }

        respond "Forbidden" 403
      }
    '';
  };

  services.caddy.virtualHosts."development.deprived.dev" = {
    extraConfig = ''
      reverse_proxy * 127.0.0.1:5173
    '';
  };

  services.caddy.virtualHosts."internal.deprived.dev" = {
    extraConfig = ''
      # Only allow GET + POST
      @not_allowed {
        not method GET POST
      }
      respond @not_allowed 405

      # Auth (same as before): require auth for non-POST (i.e., GET)
      @protected {
        not method POST
      }
      basicauth @protected {
        git $2a$14$VlDba5ipUmRYKPYmjPql8.pa8vO7cYsmUf26cXzTk.MbHoRA/ZKJy
      }

      # /backup → 127.0.0.1:3435
      @backup path /backup*
      reverse_proxy @backup 127.0.0.1:3435

      # everything else → 127.0.0.1:3322
      reverse_proxy * 127.0.0.1:3322

    '';
  };
}
