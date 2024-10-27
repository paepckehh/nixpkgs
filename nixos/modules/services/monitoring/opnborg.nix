{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.opnborg;
in {
  options.services.opnborg = {
    enable = mkEnableOption "opnborg";
    
    user = mkOption {
      type = types.str;
      default = "opnborg";
      defaultText = "opnborg";
      description = "The local user to run OPNBorg on this computer with.";
    };

    extraOptions = mkOption {
      type = with types; attrsOf str;
      default = {};
      example = ''
        # minimal
        "OPN_TARGETS" = "opn01.lan";
        "OPN_APIKEY" = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
        "OPN_APISECRET" = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
        # complex
        "OPN_APIKEY" = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
        "OPN_APISECRET" = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
        "OPN_TLSKEYPIN" = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
        "OPN_MASTER" = "opn00.lan:8443";
        "OPN_TARGETS_HOTSTANDBY" = "opn00.lan:8443";
        "OPN_TARGETS_PRODUCTION" = "opn01.lan:8443,opn02.lan:8443";
        "OPN_TARGETS_IMGURL_HOTSTANDBY" = "https://icon-library.com/images/freebsd-icon/freebsd-icon-16.jpg";
        "OPN_TARGETS_IMGURL_PRODUCTION" = "https://icon-library.com/images/freebsd-icon/freebsd-icon-16.jpg";
        "OPN_SLEEP" = "60";
        "OPN_DEBUG" = "true";
        "OPN_SYNC_PKG" = "true";
        "OPN_HTTPD_ENABLE" = "true";
        "OPN_HTTPD_SERVER" = "127.0.0.1:6464";
        "OPN_HTTPD_COLOR_FG" = "white";
        "OPN_HTTPD_COLOR_BG" = "grey";
        "OPN_RSYSLOG_ENABLE" = "true";
        "OPN_RSYSLOG_SERVER" = "192.168.122.1:5140";
        "OPN_GRAFANA_WEBUI" = "http://localhost:9090";
        "OPN_GRAFANA_DASHBOARD_FREEBSD" = "Kczn-jPZz/node-exporter-freebsd";
        "OPN_GRAFANA_DASHBOARD_HAPROXY" = "rEqu1u5ue/haproxy-2-full";
        "OPN_WAZUH_WEBUI" = "http://localhost:9292";
        "OPN_PROMETHEUS_WEBUI" = "http://localhost:9191";
        '';
      description = ''
        Additional setup enviroment variables
        Details and more examples: https://github.com/paepckehh/opnborg
        '';
    };
  };

  config = mkIf config.services.opnborg.enable {
    users = {
      users = optionalAttrs (cfg.user == "opnborg") {
        opnborg = {
          description = "opnborg service user";
          isSystemUser = true;
          group = "opnborg";
        };
      };
      groups = optionalAttrs (cfg.user == "opnborg") {opnborg = {};};
    };

    environment.systemPackages = [pkgs.opnborg];

    systemd.services.opnborg = {
      after = ["network.target"];
      wantedBy = [ "multi-user.target" ];
      description = "OPNBorg Service";
      environment = cfg.extraOptions; 
      serviceConfig = {
        ExecStart = "${pkgs.opnborg}/bin/opnborg";
        KillMode = "process";
        Restart = "always";
        User = cfg.user;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RuntimeDirectory = "opnborg";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        RestrictRealtime = true;
        PrivateMounts = true;
        MemoryDenyWriteExecute = true;
      };
    };

  };

  meta.maintainers = with maintainers; [paepcke];
}
