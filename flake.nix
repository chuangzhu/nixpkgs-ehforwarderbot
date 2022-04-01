{
  description = "EH Forwarder Bot overlay for Nixpkgs, and module for NixOS.";
  outputs = { self, ... }: {
    overlay = import ./overlay.nix;
    nixosModules.ehforwarderbot = import ./module.nix;
  };
}
