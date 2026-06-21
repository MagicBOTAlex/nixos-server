_: {
  services.netbird = {
    enable = true;
    useRoutingFeatures = "both"; # Lets this node be a routing peer to access pods
  };
}
