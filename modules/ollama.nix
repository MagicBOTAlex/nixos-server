{ pkgs, lib, ... }: {
  services.ollama = {
    host = "0.0.0.0";
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      CUDA_VISIBLE_DEVICES = "0";
    };

  };
  networking.firewall.allowedTCPPorts = [ 11434 ];

}

