{pkgs,...} : {
  environment.systemPackages = with pkgs; [
    neovim
    wget
    iproute2
    curl
    fastfetch
    tree
    btop-cuda
    pigz
    ncdu
    screen
    nixfmt-tree
    ffmpeg-full
    borgbackup
  ];

  programs.starship.enable = true;
}
