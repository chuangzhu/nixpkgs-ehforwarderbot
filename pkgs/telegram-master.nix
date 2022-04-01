{ lib, python3Packages, python-bullet, ehforwarderbot, python-language-tags }:

with python3Packages;

buildPythonPackage rec {
  pname = "ehforwarderbot-telegram-master";
  version = "2.2.4";
  src = fetchPypi {
    pname = "efb-telegram-master";
    inherit version;
    sha256 = "sha256-q0DJyXZWkhzjORlK+RulbNtmgP6pouxQFmSbYgWRn0Q=";
  };

  patches = [ ./0001-disable-ffmpeg-installation-check.patch ];

  propagatedBuildInputs = [
    ehforwarderbot
    python-telegram-bot
    python_magic
    ffmpeg-python
    peewee
    requests
    pydub
    ruamel-yaml
    pillow
    python-language-tags
    retrying
    python-bullet
    cjkwrap
    humanize
    typing-extensions
    setuptools
  ];

  doCheck = false;
}
