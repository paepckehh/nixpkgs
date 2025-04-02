{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.tibber;
  inherit (lib) mkOption types concatStringsSep;
in
{
  port = 8080;
  extraOpts = {
    apiToken = mkOption {
      type = types.str;
      default = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE";
      description = ''
        Add here your personal Tibber API Token ('Bearer Token').
        Get your personal Tibber API Token here: https://developer.tibber.com
        Do not share your personal plaintext Tibber API Token via github. (see: ryantm/agenix, mic92/sops)
        The default token will only provide some synthetic invalid sample data.
      '';
    };
  };
  serviceOpts = {
    environment = {
      TIBBER_TOKEN = cfg.apiToken;
    };
    serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      Restart = "on-failure";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      ExecStart = ''
        ${pkgs.prometheus-tibber-exporter}/bin/tibber-exporter \
        --listen-address ${cfg.listenAddress}:${toString cfg.port} \
        ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
