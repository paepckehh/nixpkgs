{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.services.prometheus.exporters.tibber;
  inherit (lib) concatStringsSep;
in {
  port = 8080;
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-tibber-exporter}/bin/tibber-exporter \
          --listen-address ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
