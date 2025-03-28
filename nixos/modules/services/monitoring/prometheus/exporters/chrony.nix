{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.services.prometheus.exporters.chrony;
  inherit (lib) concatStringsSep;
in {
  port = 9123;
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-chrony-exporter}/bin/chrony_exporter \
          --bind ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
