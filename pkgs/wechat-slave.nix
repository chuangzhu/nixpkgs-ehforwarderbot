{ lib, python3Packages, python-bullet, ehforwarderbot }:

with python3Packages;

buildPythonPackage rec {
  pname = "ehforwarderbot-wechat-slave";
  version = "2.0.7";
  src = fetchPypi {
    pname = "efb-wechat-slave";
    inherit version;
    sha256 = "sha256-EFHR5Md22mlNeuiJBfSq12In4EgOzQpgjgt60zVAChw=";
  };

  prePatch = ''
    substituteInPlace setup.py \
      --replace pypng purepng
  '';
  propagatedBuildInputs = [
    ehforwarderbot
    python_magic
    pillow
    pyqrcode
    purepng
    pyyaml
    requests
    typing-extensions
    python-bullet
    cjkwrap
    setuptools
  ];

  doCheck = false;
}
