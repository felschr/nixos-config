{ buildPythonPackage, fetchPypi, setuptools, aiohttp }:

buildPythonPackage rec {
  pname = "pydeconz";
  version = "77";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8AlygjJqAjHwwjLJJM7bNEajgQ9UDQ9gB8m7wMNgBuw=";
  };

  propagateBuildInputs = [ setuptools ];
  buildInputs = [ aiohttp ];
  doCheck = false;
}
