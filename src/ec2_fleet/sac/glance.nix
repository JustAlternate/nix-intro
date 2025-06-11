_: {
  imports = [
    ./glance_pages.nix
  ];

  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      port = 8080;
      host = "0.0.0.0";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "0.0.0.0" = {
        locations."/" = {
          proxyPass = "http://localhost:8080";
        };
      };
    };
  };
}
