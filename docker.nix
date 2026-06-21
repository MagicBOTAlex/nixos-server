{ pkgs, ... }: {
    virtualisation.docker.daemon.settings.features.cdi = true;

    virtualisation.docker = {
  enable = true;
  
  extraOptions = ''
    --ipv6 
    --fixed-cidr-v6="fd00:ffff::/64"
  '';
};

  hardware.nvidia-container-toolkit.enable = true;

  # systemd.user.services.force-start-docker-containers = {
  #   description = "docker stupid, so this starts the docker composes";
  #
  #   wantedBy = [ "multi-user.target" ];
  #
  #   serviceConfig = {
  #     ExecStart = "/home/botserver/scripts/docker/up.sh";
  #     Type = "oneshot";
  #   };
  # };
}
