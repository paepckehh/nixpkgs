{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.prometheus.exporters.tibber;
  inherit (lib) mkOption types concatStringsSep;
in {
  port = 8080;
  extraOpts = {
    apiTokenPath = mkOption {
      type = types.path;
      default = null;
      description = ''
        Add here your personal Tibber API Token ('Bearer Token') File.
        Get your personal Tibber API Token here: https://developer.tibber.com
        Do not share your personal plaintext Tibber API Token via github. (see: ryantm/agenix, mic92/sops)
        The provided default token will only provide some synthetic invalid sample data.
      '';
    };
  };
  serviceOpts = {
    script = ''
      export TIBBER_TOKEN="$(cat ${toString cfg.apiTokenPath}"
      exec ${pkgs.prometheus-tibber-exporter}/bin/tibber-exporter --listen-address ${cfg.listenAddress}:${toString cfg.port} ${concatStringsSep " \\\n  " cfg.extraFlags}
    '';
    serviceConfig = {
      AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
      CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      Restart = "on-failure";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
    };
  };
}
