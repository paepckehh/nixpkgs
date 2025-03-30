{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.services.prometheus.exporters.ecoflow;
  inherit (lib) concatStringsSep;
in {
  port = 2112;
  serviceOpts = {
    environment = {
      PROMETHEUS_ENABLED = "true";
    };
    serviceConfig = {
      ExecStart = ''
        ${pkgs.go-ecoflow-exporter}/bin/go-ecoflow-exporter \
          --bind ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
