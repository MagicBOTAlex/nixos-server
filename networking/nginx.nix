{ pkgs, ... }:

{
  imports = [ ./networkSetup.nix ];

  services.nginx = {
    enable = true;
    
    # Highly recommended: automatically adds standard proxy headers 
    # (Host, X-Real-IP, X-Forwarded-For, etc.) mirroring Caddy's default behavior.
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    # Global mapping for API / Pocket CORS validation
    appendHttpConfig = ''
      map $http_origin $is_valid_origin {
          default 0;
          "~*^https?://(localhost(:\d+)?|([a-z0-9-]+\.)*deprived\.dev)$" 1;
      }
    '';

    virtualHosts = {

      # --- Simple Proxies ---

      "immich.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:2283";
      "ha.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:8123";
      "argocd.deprived.dev".locations."/".proxyPass = "http://10.0.0.2:4325";
      "webui.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:3000";
      "jelly.deprived.dev".locations."/".proxyPass = "http://10.0.0.2:8096";
      "netbird.deprived.dev".locations."/".proxyPass = "http://10.0.0.2:3324";
      "seer.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:5055";
      "penpot.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:5544";
      "www.akupunktur-herlev.dk".locations."/".proxyPass = "http://127.0.0.1:6642";
      "lyrics.hook.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:7576";
      "docker.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:5000";
      "docker.ui.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:6842";
      "zhenss.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:8388";
      "zcol.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:7577";
      "zcollection.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:7577";
      "zcollection.mcd.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:7578";
      "development.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:5173";
      "dev.hook.deprived.dev".locations."/".proxyPass = "http://127.0.0.1:3322";

      # --- Redirects ---
      
      "yaaumma.com".globalRedirect = "www.yaaumma.com";
      "akupunktur-herlev.dk".globalRedirect = "www.akupunktur-herlev.dk";

      # --- Complex Proxies ---

      "devcam.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://192.168.50.85:80";
          extraConfig = ''
            set $auth "Restricted";
            if ($request_method = OPTIONS) {
                set $auth off;
            }
            auth_basic $auth;
            auth_basic_user_file /etc/nginx/.htpasswd-alex;
          '';
        };
      };

      "api.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:6333";
          extraConfig = ''
            set $bad_origin 0;
            if ($http_origin != "") { set $bad_origin 1; }
            if ($is_valid_origin = 1) { set $bad_origin 0; }
            if ($bad_origin = 1) { return 403 "CORS origin not allowed"; }

            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE" always;
                add_header Access-Control-Allow-Headers $http_access_control_request_headers always;
                add_header Access-Control-Max-Age "3600" always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Vary "Origin" always;
                return 204;
            }

            proxy_hide_header Access-Control-Allow-Origin;
            proxy_hide_header Access-Control-Allow-Methods;
            proxy_hide_header Access-Control-Allow-Headers;
            proxy_hide_header Access-Control-Allow-Credentials;
            proxy_hide_header Access-Control-Expose-Headers;
            proxy_hide_header Vary;

            if ($is_valid_origin = 1) {
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Access-Control-Expose-Headers "Authorization" always;
                add_header Vary "Origin" always;
            }
          '';
        };
      };

      "pocket.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3433";
          extraConfig = ''
            set $bad_origin 0;
            if ($http_origin != "") { set $bad_origin 1; }
            if ($is_valid_origin = 1) { set $bad_origin 0; }
            if ($bad_origin = 1) { return 403 "CORS origin not allowed"; }

            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE" always;
                add_header Access-Control-Allow-Headers $http_access_control_request_headers always;
                add_header Access-Control-Max-Age "3600" always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Vary "Origin" always;
                return 204;
            }

            proxy_hide_header Access-Control-Allow-Origin;
            proxy_hide_header Access-Control-Allow-Methods;
            proxy_hide_header Access-Control-Allow-Headers;
            proxy_hide_header Access-Control-Allow-Credentials;
            proxy_hide_header Access-Control-Expose-Headers;
            proxy_hide_header Vary;

            if ($is_valid_origin = 1) {
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Access-Control-Expose-Headers "Authorization" always;
                add_header Vary "Origin" always;
            }
          '';
        };
      };

      "spotify.playing.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8800";
          extraConfig = ''
            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers $http_access_control_request_headers always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Access-Control-Max-Age "600" always;
                add_header Vary "Origin" always;
                return 204;
            }

            set $auth "Restricted";
            if ($request_method = OPTIONS) { set $auth off; }
            auth_basic $auth;
            auth_basic_user_file /etc/nginx/.htpasswd-alex;

            add_header Access-Control-Allow-Origin $http_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers $http_access_control_request_headers always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Vary "Origin" always;
          '';
        };
      };

      "spotify.api.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:4142";
          extraConfig = ''
            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Origin $http_origin always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization" always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Vary "Origin" always;
                return 204;
            }

            set $auth "Restricted";
            if ($request_method = OPTIONS) { set $auth off; }
            auth_basic $auth;
            auth_basic_user_file /etc/nginx/.htpasswd-alex;

            proxy_hide_header Access-Control-Allow-Origin;

            add_header Access-Control-Allow-Origin $http_origin always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization" always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Vary "Origin" always;
          '';
        };
      };

      "lyrics.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:7444";
          extraConfig = ''
            if ($request_method = OPTIONS) {
                add_header Access-Control-Allow-Origin "*" always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization" always;
                return 204;
            }
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization" always;
          '';
        };
      };

      "direct.stream.deprived.dev" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:3344";
          extraConfig = ''
            if ($arg_key != "0c156f3d-dc1d-489f-866e-69e306249e92") {
                return 403 "Forbidden";
            }
          '';
        };
      };

      "internal.deprived.dev" = {
        extraConfig = ''
          if ($request_method !~ ^(GET|POST)$) {
              return 405;
          }

          # Require auth for GET, bypass for POST
          set $auth "Restricted";
          if ($request_method = POST) {
              set $auth off;
          }
        '';

        locations."^~ /backup" = {
          proxyPass = "http://127.0.0.1:3435";
          extraConfig = ''
            auth_basic $auth;
            auth_basic_user_file /etc/nginx/.htpasswd-git;
          '';
        };

        locations."/" = {
          proxyPass = "http://127.0.0.1:3322";
          extraConfig = ''
            auth_basic $auth;
            auth_basic_user_file /etc/nginx/.htpasswd-git;
          '';
        };
      };
      
    };
  };
}
