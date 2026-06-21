{ pkgs, ... }: {
  imports = [
    ./kubelet.nix 
    ./containerd.nix
    ./netbird.nix
  ];
  environment.systemPackages = with pkgs; [ kubernetes cri-tools ];
}
