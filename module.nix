{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ehforwarderbot;
  package = pkgs.python3.withPackages (_: [ pkgs.ehforwarderbot ] ++ cfg.modules);
  settingsFormat = pkgs.formats.yaml { };

  profileOpts.options = {
    masterChannel = {
      id = mkOption {
        type = types.str;
        example = "blueset.telegram";
        description = ''
          Master channel ID. See <link xlink:href="https://github.com/ehForwarderBot/ehForwarderBot/wiki/Modules-Repository"
          >https://github.com/ehForwarderBot/ehForwarderBot/wiki/Modules-Repository</link>
          for a list of channel IDs.
        '';
      };
      config = mkOption {
        type = types.attrs;
        example = {
          token = "012345678:1Aa2Bb3Vc4Dd5Ee6Gg7Hh8Ii9Jj0Kk1Ll2M";
          admins = [ 102938475 91827364 ];
        };
        description = ''
          Master channel configurations. See the documentation of the module you use.

          Note that any secrets passed here is world-readable in the Nix store.
          You can instead pass the secrets using <option>environmentFile</option>.
        '';
      };
    };
    slaveChannels = mkOption {
      type = types.attrsOf types.attrs;
      example = {
        "blueset.wechat" = { };
      };
      description = ''
        Each attribute name denotes the ID of the channel to use,
        and the corresponding attribute value is the configuration of the channel.
        See the documentation of the module you use.
      '';
    };
    middlewares = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      example = {
        "blueset.gpg" = {
          key = "BD6B65EC00638DC9083781D5D4B65BB1A106200A";
          password = "correcthorsebatterystaple";
          binary = literalExpression "\${pkgs.gnupg}/bin/gpg";
          server = "pgp.mit.edu";
        };
      };
      description = ''
        Same as <option>slave_channels</option>, but for middlewares.
      '';
    };

    environmentFile = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/var/lib/hedgedoc/hedgedoc.env";
      description = ''
        Environment file as defined in <citerefentry>
        <refentrytitle>systemd.exec</refentrytitle><manvolnum>5</manvolnum>
        </citerefentry>.

        Secrets may be passed to the service without adding them to the world-readable
        Nix store, by specifying placeholder variables as the option value in Nix and
        setting these variables accordingly in the environment file.

        <programlisting>
          # snippet of ehForwarderBot-related config
          services.ehforwarderbot.profiles.default.masterChannel.config.token = "$MASTER_CHANNEL_TOKEN";
        </programlisting>

        <programlisting>
          # content of the environment file
          MASTER_CHANNEL_TOKEN=012345678:1Aa2Bb3Vc4Dd5Ee6Gg7Hh8Ii9Jj0Kk1Ll2M
        </programlisting>

        Note that this file needs to be available on the host on which
        <literal>ehForwarderBot</literal> is running.
      '';
    };
  };

  generateProfileConfig = profile:
    settingsFormat.generate "config.yaml" {
      master_channel = profile.masterChannel.id;
      slave_channels = attrNames profile.slaveChannels;
      middlewares = attrNames profile.middlewares;
    };

  allChannels = profile: with profile;
    { ${masterChannel.id} = masterChannel.config; } // slaveChannels // middlewares;

  generateSystemdService = name: profile:
    nameValuePair "ehforwarderbot-${name}" {
      description = "EH Forwarder Bot profile ${name}";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p $STATE_DIRECTORY/profiles/${name}/
        ln -sf ${generateProfileConfig profile} $STATE_DIRECTORY/profiles/${name}/config.yaml

        # Substitude to tmpfs and is safer than to disk

        ${concatStringsSep "\n" (
          mapAttrsToList (id: config: ''
            mkdir -p {$STATE_DIRECTORY,$RUNTIME_DIRECTORY}/profiles/${name}/${id}
            ${pkgs.envsubst}/bin/envsubst \
              -i ${settingsFormat.generate "${id}.yaml" config} \
              -o $RUNTIME_DIRECTORY/profiles/${name}/${id}/config.yaml
            ln -sf {$RUNTIME_DIRECTORY,$STATE_DIRECTORY}/profiles/${name}/${id}/config.yaml
          '') (allChannels profile)
        )}
      '';
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "ehforwarderbot";
        Environment = [ "EFB_DATA_PATH=/var/lib/ehforwarderbot" ];
        RuntimeDirectory = "ehforwarderbot";
        ExecStart = "${package}/bin/ehforwarderbot -p ${name}";
        EnvironmentFile = profile.environmentFile;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        PrivateUsers = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        CapabilityBoundingSet = [ ];
        ProtectHostname = true;
        ProcSubset = "pid";
        SystemCallArchitectures = "native";
        UMask = "0077";
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
      };
    };
in

{
  # Interface
  options.services.ehforwarderbot = {
    enable = mkEnableOption "EH Forwarder Bot";
    profiles = mkOption {
      type = types.attrsOf (types.submodule profileOpts);
      description = "https://ehforwarderbot.readthedocs.io/en/latest/config.html";
    };
    modules = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression
        "with pkgs; [ ehforwarderbot-telegram-master ehforwarderbot-wechat-slave ]";
    };
  };

  # Implementation
  config = mkIf cfg.enable {
    systemd.services = mapAttrs' generateSystemdService cfg.profiles;
  };
}
