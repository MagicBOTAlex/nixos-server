{ pkgs, ... }: {
  imports = [ ./kublet.nix ];
  environment.systemPackages = with pkgs; [ kubernetes ];
}
