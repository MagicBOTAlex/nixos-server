# Forgejo Actions runner for https://git.deprived.dev
#
# The runner is pre-registered on the Forgejo instance, so no interactive
# registration is needed. To keep the runner token out of the nix store, the
# config loads it from a file. The `forgejo-runner` user and
# /var/lib/forgejo-runner are created by the first `nrb` (via tmpfiles), so
# write the token file afterwards and restart the service:
#
#   printf '%s' 'YOUR_FORGEJO_RUNNER_TOKEN' | sudo tee /var/lib/forgejo-runner/token >/dev/null
#   sudo chmod 600 /var/lib/forgejo-runner/token
#   sudo chown forgejo-runner:forgejo-runner /var/lib/forgejo-runner/token
#   sudo systemctl restart forgejo-runner
#
# The service retries until the file appears.
{ pkgs, ... }:
let
  runnerConfig = (pkgs.formats.yaml { }).generate "forgejo-runner.yaml" {
    log.level = "info";

    runner = {
      capacity = 1;
      # Must match the `runs-on:` labels used by workflows in git.deprived.dev.
      labels = [ "native:host" ];
    };

    cache.enabled = true;

    server.connections.forgejo = {
      url = "https://git.deprived.dev/";
      uuid = "f9f44633-069e-4f6b-8884-df4dd3e42442";
      token_url = "file:/var/lib/forgejo-runner/token";
    };
  };
in
{
  users.users.forgejo-runner = {
    isSystemUser = true;
    group = "forgejo-runner";
    extraGroups = [ "docker" ];
  };
  users.groups.forgejo-runner = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/forgejo-runner 0750 forgejo-runner forgejo-runner -"
  ];

  systemd.services.forgejo-runner = {
    description = "Forgejo Actions Runner";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "docker.service" ];

    environment.HOME = "/var/lib/forgejo-runner";
    # Tools available to host-executed ("native:host") jobs.
    path = with pkgs; [
      bash
      coreutils
      curl
      gitMinimal
      gnused
      openssh
      wget
    ];

    serviceConfig = {
      User = "forgejo-runner";
      Group = "forgejo-runner";
      WorkingDirectory = "/var/lib/forgejo-runner";
      ExecStart = "${pkgs.forgejo-runner}/bin/forgejo-runner daemon --config ${runnerConfig}";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
