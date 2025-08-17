{pkgs, ...}: {
  users.users.botserver = {
    isNormalUser = true;
    description = "botserver";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "starr"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhiPhFbCi64NduuV794omgS8mctBLXtqxbaEJyUo6lg botalex@DESKTOPSKTOP-ENDVV0V"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFhTExbc9m4dCK6676wGiA8zPjE0l/9Fz2yf0IKvUvg snorre@archlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxUPAsPkri0B+xkO3sCHJZfKgAbgPcepP8J4WW4yyLj u0_a167@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfQLOKUnOARUAs8X1EL1GRHoCQ0oMun0vzL7Z78yOsM nixos@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw1ckvXz78ITeqANrWSkJl6PJo2AMA4myNrRMBAB7xW zhentao2004@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0K0fj9fJAgBrajHQJWRe0lKkmyjOUAjVn5S5zsVAQL redux@solituboks"
    ];
  };

  users.users.starr = {
      isNormalUser = true;
      description = "For jellyfin";
      extraGroups = [
          "starr"
        ];
    };

  users.groups."starr" = {};
}
