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
    apiTokeFile = mkOption {
      type = types.path;
      default = null;
      example = /etc/nixos/.keys/tibber.txt;
      description = ''
        File containing your personal Tibber API Token ('Bearer Token').
        Api Token File example content (non-functional!): 5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE
        Do not share your Tibber API Token with anyone!
        Do not commit you Tibber API Token to you github repo!
      '';
    };
  };
  serviceOpts = {
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
        TIBBER_TOKEN=$(cat ${cfg.apiTokenFile}) \
        ${pkgs.prometheus-tibber-exporter}/bin/tibber-exporter \
        --listen-address ${cfg.listenAddress}:${toString cfg.port} \
        ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
