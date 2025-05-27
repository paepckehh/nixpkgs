{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.encrypted-dns-server;
in
{
  options.services.encrypted-dns-server = {
    enable = mkEnableOption "encrypted-dns-server";

    settings = mkOption {
      description = ''
        Attrset that is converted and passed as TOML config file.
        For available params, see: <https://github.com/DNSCrypt/encrypted-dns-server/blob/${pkgs.encrypted-dns-server.version}/encrypted-dns-server/example-encrypted-dns.toml>
      '';
      example = literalExpression ''
        {
        upstream_addr = "1.1.1.1:53";
        daemonize = true;
        }
      '';
      type = types.attrs;
      default = { };
    };

    upstreamDefaults = mkOption {
      description = ''
        Whether to base the config declared in {option}`services.encrypted-dns-server.settings` on the upstream example config (<https://raw.githubusercontent.com/DNSCrypt/encrypted-dns-server/refs/heads/master/example-encrypted-dns.toml>)

        Disable this if you want to declare your dnscrypt config from scratch.
      '';
      type = types.bool;
      default = true;
    };

    configFile = mkOption {
      description = ''
        Path to TOML config file. See: <https://raw.githubusercontent.com/DNSCrypt/encrypted-dns-server/refs/heads/master/example-encrypted-dns.toml>
        If this option is set, it will override any configuration done in options.services.encrypted-dns-server.settings.
      '';
      example = "/etc/encrypted-dns-server/config.toml";
      type = types.path;
      default =
        pkgs.runCommand "encrypted-dns-server.toml"
          {
            json = builtins.toJSON cfg.settings;
            passAsFile = [ "json" ];
          }
          ''
            ${
              if cfg.upstreamDefaults then
                ''
                  ${pkgs.buildPackages.remarshal}/bin/toml2json ${pkgs.encrypted-dns-server.src}/encrypted-dns-server/example-encrypted-dns.toml > example.json
                  ${pkgs.buildPackages.jq}/bin/jq --slurp add example.json $jsonPath > config.json # merges the two
                ''
              else
                ''
                  cp $jsonPath config.json
                ''
            }
            ${pkgs.buildPackages.remarshal}/bin/json2toml < config.json > $out
          '';
      defaultText = literalMD "TOML file generated from {option}`services.encrypted-dns-server.settings`";
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = lib.mkDefault [ "127.0.0.1" ];

    systemd.services.encrypted-dns-server = {
      description = "encrypted dns server";
      wants = [
        "network-online.target"
        "nss-lookup.target"
      ];
      before = [ "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CacheDirectory = "encrypted-dns-server";
        DynamicUser = true;
        ExecStart = "${pkgs.encrypted-dns-server}/bin/encrypted-dns-server -config ${cfg.configFile}";
        LockPersonality = true;
        LogsDirectory = "encrypted-dns-server";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        NonBlocking = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "always";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "encrypted-dns-server";
        StateDirectory = "encrypted-dns-server";
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "@chown"
          "~@aio"
          "~@keyring"
          "~@memlock"
          "~@setuid"
          "~@timer"
        ];
      };
    };
  };

  meta.buildDocsInSandbox = false;
}
