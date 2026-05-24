{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cake-autorate;

  renderValue =
    value: if builtins.isInt value || builtins.isFloat value then toString value else "\"${value}\"";

  configFile = pkgs.writeText "cake-autorate-config.sh" (
    lib.concatLines (lib.mapAttrsToList (key: value: "${key}=${renderValue value}") cfg.settings)
  );
in
{
  options.services.cake-autorate = {
    enable = lib.mkEnableOption "cake-autorate, automatic CAKE bandwidth adjustment";

    settings = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.int
          lib.types.float
          lib.types.str
        ]
      );
      default = { };
      example = lib.literalExpression ''
        {
          dl_if = "ifb-wan";
          ul_if = "wan";
          min_dl_shaper_rate_kbps = 5000;
          base_dl_shaper_rate_kbps = 20000;
          max_dl_shaper_rate_kbps = 80000;
          min_ul_shaper_rate_kbps = 5000;
          base_ul_shaper_rate_kbps = 20000;
          max_ul_shaper_rate_kbps = 35000;
        }
      '';
      description = ''
        Settings for cake-autorate, corresponding to variables defined in
        [defaults.sh](https://github.com/lynxthecat/cake-autorate/blob/master/defaults.sh).
        Integer and float values are rendered directly; string values are quoted.
        Boolean flags use integers: `1` to enable, `0` to disable.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cake-autorate = {
      description = "cake-autorate - automatic CAKE bandwidth adjustment";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.cake-autorate} ${configFile}";
        Restart = "on-failure";
        RestartSec = "5";
        # cake-autorate uses tc for CAKE qdisc management and ping for latency probing
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
        ];
        NoNewPrivileges = true;
        ProtectHome = true;
      };
    };
  };
}
