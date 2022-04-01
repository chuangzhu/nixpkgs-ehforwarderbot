final: prev:

rec {
  python-bullet = prev.callPackage ./pkgs/python-bullet.nix { };
  python-language-tags = prev.callPackage ./pkgs/python-language-tags.nix { };

  ehforwarderbot = prev.callPackage ./pkgs/ehforwarderbot.nix { };
  ehforwarderbot-telegram-master = prev.callPackage ./pkgs/telegram-master.nix { };
  ehforwarderbot-wechat-slave = prev.callPackage ./pkgs/wechat-slave.nix { };
}
