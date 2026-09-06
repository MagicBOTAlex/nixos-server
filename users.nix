{ pkgs, ... }: {
  users.users.botserver = {
    isNormalUser = true;
    description = "botserver";
    extraGroups = [ "networkmanager" "wheel" "docker" "starr" "kubernetes" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhiPhFbCi64NduuV794omgS8mctBLXtqxbaEJyUo6lg botalex@DESKTOPSKTOP-ENDVV0V"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFhTExbc9m4dCK6676wGiA8zPjE0l/9Fz2yf0IKvUvg snorre@archlinux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxUPAsPkri0B+xkO3sCHJZfKgAbgPcepP8J4WW4yyLj u0_a167@localhost"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfQLOKUnOARUAs8X1EL1GRHoCQ0oMun0vzL7Z78yOsM nixos@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJw1ckvXz78ITeqANrWSkJl6PJo2AMA4myNrRMBAB7xW zhentao2004@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA0K0fj9fJAgBrajHQJWRe0lKkmyjOUAjVn5S5zsVAQL redux@solituboks"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhcUZbIMX0W27l/FMF5WijpdsJAK329/P008OEAfcyz botmain@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyZOZlcQBmqSPxjaGgE2tP+K7LYziqjFUo3EX12rGtf botlap@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHo3J4vGo2eWzwXU2K6kaom8pmElX+PaAuasH5BWQ9v7 root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILB0esg3ABIcYWxvQKlPuwEE6cbhNcWjisfky0wnGirJ root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC562Woe/yT/3dNVceN9rKPJQcvgTFzIhJVdVGv7sqn1 baritone@server"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAKGLgFg3vgf+OypPIgW9pJb+m+lbu84N1xUaFEvgpET u0_a219@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1EIniHJtC4VmD5hRKy5+LjG0tCLmPTy+s9Z7GnrW5a1sGeo5J30I6sZSNaakF3LDlbJBsjD/pz6XhIOT2qSXEAH7diwjKA79lCHaZeAsrj4nLsYkC3Z/svODRLStp6e+rPFE+WIfy9CvDtGZnCzcNaic7OiUD7CdxBF/AP2gMkHFRiS4VWWE8/ZBt0o8AnUyvlO1rTzrlM29ag4ycf9EhBkgk1HsSpQZiXqMNmFtygoylrY504TZXRm8q1Wx2WUkNm6ETHvtx7LmMnEkATwCqScLSAp65o/55PWjY3sQ0ncCAfH7dYMgNwk+ZCLMkB2jWA7JEWPkgcz8siZZHxhrp u0_a430@localhost
"
    ];
  };

  users.motd = "Server DEPRIVED of good internet";

  users.users.starr = {
    isNormalUser = true;
    description = "For jellyfin";
    extraGroups = [ "starr" ];
  };

  users.users.builder = {
    isNormalUser = true;
    description = "For test case building and such";
    extraGroups = [ "docker" ];
  };

  users.groups."starr" = { };
}
