{ pkgs, ... }:
let
  ports =
    [
      51820
      2283
      8123
      4325
      443
      80
      3000
      8096
      3324
      5055
      5544
      6642
      6333
      3433
      8800
      4142
      7444
      7576
      5000
      6842
      8388
      7578
      3344
      5173
      3322
      22
      22222
      8888
      9400
      8877
      6443
      5533
      4222
      4223
      5353
      8081
      6052
      6055





    ];
in
{
  networking.firewall.allowedUDPPorts = ports;
  networking.firewall.allowedTCPPorts = ports;
}
