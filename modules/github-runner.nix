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

  services.github-runners = {
    countr-runner = {
      enable = true;
      url = "https://github.com/Countr-Electronics/Firmware";
      tokenFile = "/var/lib/github-runner/token";
      extraLabels = [ "nixos" "production" ];

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
    ot-nrf-runner = {
      enable = true;
      url = "https://github.com/MagicBOTAlex/nrf52840-OpenThread"; # Or organization URL
      tokenFile = "/var/lib/github-runner/token";

      # Custom labels to target this runner in your GitHub workflows
      extraLabels = [ "nixos" "production" ];

      # Packages available to the runner script execution environment
      extraPackages = with pkgs; [
        git
        curl
        gnumake
        cmake
        nodejs_20 # Essential for GitHub Actions runner

        # ARM Cross-compiler and C libraries required for nRF52840
        gcc-arm-embedded
        libossp_uuid # Often required by tools handling firmware IDs

        # Python environment with required tools (nrfutil equivalent or dependencies)
        (python3.withPackages (ps: with ps; [
          pip
          setuptools
          # Note: 'nrfutil' is proprietary and usually not in nixpkgs. 
          # If your build script strictly relies on it, we can fetch it or use a shell.
        ]))
      ];
    };
  };
}
