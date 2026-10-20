# sudo mkdir -p /var/lib/github-runner
# echo "YOUR_GITHUB_TOKEN_HERE" | sudo tee /var/lib/github-runner/token
# sudo chmod 600 /var/lib/github-runner/token
{ pkgs, ... }: {
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-20.20.2"
    "nodejs-slim-20.20.2"
    "nodejs-20.18.1"
  ];
  users.users.github-runner = {
    isSystemUser = true;
    group = "github-runner";
    extraGroups = [ "docker" ];
  };
  users.groups.github-runner = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/github-runner/countr-runner-work 0700 github-runner github-runner -"
  ];

  services.github-runners = {
    countr-runner-botserver = {
      enable = true;
      url = "https://github.com/Countr-Electronics";
      tokenFile = "/var/lib/github-runner/countr/token";
      extraLabels = [ "nixos" "production" ];
      workDir = "/var/lib/github-runner/countr-runner-work";
      replace = true;

      user = "github-runner";

      package = (pkgs.github-runner.override {
        # Only request Node 24 from Nixpkgs
        nodeRuntimes = [ "node24" ];
      }).overrideAttrs (old: {
        # Symlink the expected node20 directory to node24
        postInstall = (old.postInstall or "") + ''
          ln -s $out/lib/externals/node24 $out/lib/externals/node20
        '';
      });

      extraPackages = with pkgs; [
        git
        curl
        gnumake
        nodejs
        docker
        (python3.withPackages (ps: with ps; [ pip setuptools wheel pillow ]))
        platformio
      ];

      # 2. Relax the systemd sandbox so Docker can properly mount the workspace
      serviceOverrides = {
        PrivateMounts = false;
        PrivateTmp = false;
        ReadWritePaths = [ "/var/run/docker.sock" ];

        # Allows the runner to see /proc/1/cgroup
        ProtectProc = "default";
      };
    };
  };
}
