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

    apikey = mkOption {
      type = types.str;
      default = "";
      example = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
      description = ''
        The apikey to authorise the OPNSense appliance access.
        - This will set the required "OPN_APIKEY" enviroment variable. 
        - Details: https://github.com/paepckehh/opnborg 
        '';
    };
    
    apisecret = mkOption {
      type = types.str;
      default = "";
      example = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
      description = ''
        The apisecret to authorise the OPNSense appliance access.
        - This will set the required "OPN_APISECRET" enviroment variable. 
        - Details: https://github.com/paepckehh/opnborg
        '';
    };
    
    tlskeypin = mkOption {
      type = types.str;
      default = "";
      example = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
      description = ''
        The tlskeypin of the OPNSense appliance WebUI (selfsigned-) certificate."
        - This will set the optional "OPN_TLSKEYPIN" enviroment variable.
        - Details: https://github.com/paepckehh/opnborg
        '';
    };
    
    targets = mkOption {
      type = types.str;
      default = "";
      example = "opn001.admin.lan:443,opn002.admin.lan:443,opn002.admin.lan:443,opn004.admin.lan:443";
      description = ''
         The OPNSense appliance(s) target hostname(s)[opt:port]. 
        - This will set the "OPN_TARGETS" enviroment variable.
        - This string expects a comma seperated list.
        - Either OPN_TARGETS or freeform OPN_TARGETS_[...] extraOptions enironment variables are required. 
        - Details: https://github.com/paepckehh/opnborg
        '';
    };
    
    user = mkOption {
      type = types.str;
      default = "opnborg";
      defaultText = "opnborg";
      description = "The local user to run OPNBorg on this computer with.";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ''
        {
        "OPN_TARGETS_HOTSTANDBY" = "opn00.lan:8443"
        "OPN_TARGETS_IMGURL_HOTSTANDBY" = "https://avatars.githubusercontent.com/u/120342602?s=96&v=4"
        "OPN_TARGETS_PRODUCTION='opn01.lan:8443,opn02.lan:8443"
        "OPN_TARGETS_IMGURL_HOTSTANDBY" = "https://avatars.githubusercontent.com/u/120342602?s=96&v=4"
        "OPN_SLEEP" = "60"
        "OPN_DEBUG" = "true"
        "OPN_SYNC_PKG" ="true"
        "OPN_HTTPD_ENABLE" = "true"
        "OPN_HTTPD_SERVER" = "127.0.0.1:6464"
        "OPN_HTTPD_COLOR_FG" = "white"
        "OPN_HTTPD_COLOR_BG" = "grey"
        "OPN_RSYSLOG_ENABLE='true'
        "OPN_RSYSLOG_SERVER='192.168.122.1:5140'
        "OPN_GRAFANA_WEBUI='http://localhost:9090'
        "OPN_GRAFANA_DASHBOARD_FREEBSD='Kczn-jPZz/node-exporter-freebsd'
        "OPN_GRAFANA_DASHBOARD_HAPROXY='rEqu1u5ue/haproxy-2-full'
        "OPN_WAZUH_WEBUI='http://localhost:9292'
        "OPN_PROMETHEUS_WEBUI='http://localhost:9191'
        }
        '';
      description = ''
        Additional setup enviroment variables
        - Details and more examples: https://github.com/paepckehh/opnborg
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
      description = "OPNBorg Service";

      wantedBy = ["multi-user.target"];
      after = ["network.target"];

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

      environment = {
        OPN_APIKEY = cfg.apikey;
        OPN_APISECRET = cfg.apisecret;
        OPN_TLSKEYPIN = cfg.tlskeypin;
        OPN_TARGETS = cfg.targets;
      };

    };

  };

  meta.maintainers = with maintainers; [paepcke];
}
