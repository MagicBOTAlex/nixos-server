{ pkgs, ... }: {
  # Enable OpenSSH (required for initial Mosh handshake)
  services.openssh.enable = true;

  # Enable Mosh Server (automatically opens UDP ports 60000-61000 in firewall)
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [tmux];
}
