{
  pkgs,
  ...
}:
{
  systemd.services."jelly-forward" = {
    description = "forwards jellyfin running on kubernetes";

    after = [
      "network-online.target"
      "microvm@kubernetes.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      sleep 5
      ${pkgs.kubernetes}/bin/kubectl -n jellyfin port-forward deployment/jellyfin-deployment 8096:8096 --address 0.0.0.0 || true
    '';

    serviceConfig = {
      User = "root";
      Restart = "always";
    };
  };
}
