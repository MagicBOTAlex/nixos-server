{ pkgs, ... }:
{

  networking.firewall.allowedUDPPorts = [ 1422 ];
  networking.firewall.allowedTCPPorts = [ 1422 ];

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  services.libretranslate = {
    enable = true;

    host = "0.0.0.0";
    port = 1422;

    updateModels = true;
    package = pkgs.libretranslate.override {
      python = pkgs.python3.override {
        packageOverrides = self: super: {
          ctranslate2 = super.ctranslate2.override { withCUDA = true; };
        };
      };
    };

    extraArgs = {
      "load-only" = "da,en,zh,ja";
    };
  };

  systemd.services.libretranslate.environment = {
    ARGOS_DEVICE_TYPE = "cuda";
    CUDA_VISIBLE_DEVICES = "1";
  };
}
