{ lib, python3Packages }:

with python3Packages;

buildPythonPackage rec {
  pname = "bullet";
  version = "2.2.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-36D6gYEK0anmiIFcoE8kr4f/XNvoA7QvpjSx9Q/J2Ic=";
  };
  propagatedBuildInputs = [ ];
}
