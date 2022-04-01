{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "language_tags";
  version = "1.1.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DJqCjuY7XMlIdml/TVhEmw5N6t2rM0+YOyom1peejU8=";
  };
  propagatedBuildInputs = [ ];
  doCheck = false;
}
