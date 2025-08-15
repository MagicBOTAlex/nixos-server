{pkgs, ...} : {
  programs.fish = {
    enable = true;

    shellAliases = { 
      nrb = "sudo nixos-rebuild switch --flake /etc/nixos --impure"; 
      ni = "nvim /etc/nixos/configuration.nix";
      bat="upower -i /org/freedesktop/UPower/devices/battery_BAT0| grep -E 'state|percentage'";
      gpu="nvidia-smi -q | grep -i 'draw.*W'";
      wifi="sudo nmtui";
      all="sudo chmod -R a+rwx ./*";
      ng="cd /etc/nginx/ && sudo nvim .";
      copy="xclip -sel clip";
      pubkey="cat ~/.ssh/id_ed25519.pub | copy";
      up="docker compose up -d";
      down="docker compose down";
    };

    interactiveShellInit = ''
      function enter
        if test (count $argv) -lt 1
          echo "usage: enter <container-name-or-id>"
            return 1
          end
        docker exec -it $argv[1] sh
            end
        '';
    };
    }
