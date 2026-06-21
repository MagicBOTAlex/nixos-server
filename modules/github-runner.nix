# sudo mkdir -p /var/lib/github-runner
# echo "YOUR_GITHUB_TOKEN_HERE" | sudo tee /var/lib/github-runner/token
# sudo chmod 600 /var/lib/github-runner/token
{ pkgs, ... }: {
  services.github-runners = {
    # You can define multiple distinct runners here
    my-nixos-runner = {
      enable = true;
      url = "https://github.com/Countr-Electronics/Firmware"; # Or organization URL
      tokenFile = "/var/lib/github-runner/token";

      # Custom labels to target this runner in your GitHub workflows
      extraLabels = [ "nixos" "production" ];

      # Packages available to the runner script execution environment
      extraPackages = with pkgs; [
        git
        curl
        gnumake
        nodejs # Essential for many default GitHub actions
      ];
    };
  };
}
