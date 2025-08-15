{pkgs, ...} : {
  programs.fish.enable = true;
  documentation.man.generateCaches = false;

  users.users."botserver".shell = pkgs.fish;
}
