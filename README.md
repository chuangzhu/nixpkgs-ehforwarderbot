# nixpkgs-ehforwarderbot

[EH Forwarder Bot](https://github.com/ehForwarderBot/ehForwarderBot/) overlay for Nixpkgs, and module for NixOS.

## Usage

Add `overlay.nix` into `nixpkgs.overlays` and import `module.nix` in your configuration. Or using Nix flakes:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ehforwarderbot.url = "github:chuangzhu/nixpkgs-ehforwarderbot";
  };

  outputs = { self, nixpkgs, ehforwarderbot}: {
    # Replace your-host-name to your machine's
    nixosConfigurations.your-host-name = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Include the module
        ehforwarderbot.nixosModules.ehforwarderbot
        # Add the overlay
        { nixpkgs.overlays = [ ehforwarderbot.overlay ]; }
      ];
    };
  };
}
```

Configure `service.ehforwarderbot`. See `modules.nix` for detailed explaination.

```nix
{
  services.ehforwarderbot = {
    enable = true;
    # List your modules here
    modules = with pkgs; [ ehforwarderbot-telegram-master ehforwarderbot-wechat-slave ];
    profiles.default = {
      # You can pass secrets using environmentFile
      environmentFile = config.age.secrets.ehforwarderbot.path;
      masterChannel = {
        id = "blueset.telegram";
        config = {
          token = "$MASTER_CHANNEL_TOKEN";
          admins = [ 123456 ];
        };
      };
      # Each attribute name denotes the ID of the channel to use, and the corresponding attribute value is the configuration of the channel.
      slaveChannels = {
        "blueset.wechat" = { };
      };
      # Same as slaveChannels
      middlewares = { };
    };
  };
}
```
