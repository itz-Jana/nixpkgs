{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
  filelock,
  execnet,
  pytest,
  psutil,
  setproctitle,
}:

buildPythonPackage rec {
  pname = "pytest-xdist";
  version = "3.6.1";
  disabled = pythonOlder "3.7";

  pyproject = true;

  src = fetchPypi {
    pname = "pytest_xdist";
    inherit version;
    hash = "sha256-6tFWpNsjHux2lzf1dmjvWKIISjSy5VxKj6INhhEHMA0=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ pytest ];

  dependencies = [ execnet ];

  nativeCheckInputs = [
    filelock
    pytestCheckHook
  ];

  optional-dependencies = {
    psutil = [ psutil ];
    setproctitle = [ setproctitle ];
  };

  # pytest can already use xdist at this point
  preCheck = ''
    appendToVar pytestFlagsArray "--numprocesses=$NIX_BUILD_CORES"
  '';

  # access file system
  disabledTests = [
    "test_distribution_rsyncdirs_example"
    "test_rsync_popen_with_path"
    "test_popen_rsync_subdir"
    "test_rsync_report"
    "test_init_rsync_roots"
    "test_rsyncignore"
    # flakey
    "test_internal_errors_propagate_to_controller"
    # https://github.com/pytest-dev/pytest-xdist/issues/985
    "test_workqueue_ordered_by_size"
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    changelog = "https://github.com/pytest-dev/pytest-xdist/blob/v${version}/CHANGELOG.rst";
    description = "Pytest xdist plugin for distributed testing and loop-on-failing modes";
    homepage = "https://github.com/pytest-dev/pytest-xdist";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
}
