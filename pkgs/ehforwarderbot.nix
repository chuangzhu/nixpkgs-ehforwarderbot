{ lib, python3Packages, python-bullet }:

with python3Packages;

buildPythonPackage rec {
  pname = "ehforwarderbot";
  version = "2.1.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QUw95OmtFR0604032J8LYmpfp/sE2dMP8VK1Iw00CZs=";
  };
  propagatedBuildInputs = [
    ruamel-yaml
    python-bullet
    cjkwrap
    typing-extensions
    setuptools
  ];

  doCheck = false;
}
