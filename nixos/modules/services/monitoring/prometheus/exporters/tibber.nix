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
      example = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE";
      description = ''
        Your personal Tibber API Token ('Bearer Token').
        Do not share your Tibber API Token with anyone!
        Do not commit you Tibber API Token to you github repo!
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
      ProtectClock = true;
      ProtectSystem = "strict";
      Restart = "on-failure";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      ExecStart = ''
        ${pkgs.prometheus-tibber-exporter}/bin/tibber-exporter \
        --listen-address ${cfg.listenAddress}:${toString cfg.port} \
        ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
