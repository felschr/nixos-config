{ buildPythonPackage, fetchPypi, setuptools, aiohttp }:

buildPythonPackage rec {
  pname = "pydeconz";
  version = "73";

  src = fetchPypi {
    inherit pname version;
    sha256 = "Lm7J0p2dp2gyesDpgN0WGpxPewC1z/IUy0CDEqofQGA=";
  };

  propagateBuildInputs = [ setuptools ];
  buildInputs = [ aiohttp ];
  doCheck = false;
}
