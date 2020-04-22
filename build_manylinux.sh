#!/usr/bin/env bash
set -euxo pipefail

# Downgrade auditwheel
#/opt/_internal/cpython-3.7.7/bin/pip install auditwheel==2.0.0

SKIP_PLATFORMS=(cp27-cp27m cp27-cp27mu cp34-cp34m)

for PYROOT in /opt/python/*; do
  PYTAG=$(basename "${PYROOT}")
  echo "$PYTAG"
  # Check for platforms to be skipped
  # shellcheck disable=SC2199,SC2076
  if [[ " ${SKIP_PLATFORMS[@]} " =~ " ${PYTAG} " ]]; then
    echo "skipping deprecated platform $PYTAG"
    continue
  fi

  # Create and activate virtualenv
  PYBIN="${PYROOT}/bin"
  "${PYBIN}/pip" install virtualenv
  "${PYBIN}/virtualenv" -p "${PYBIN}/python" "venv_${PYTAG}"
  # shellcheck source=/dev/null
  source "venv_${PYTAG}/bin/activate"
  #pip install -U pip setuptools wheel

  # Clean the build dir
  BUILD_DIR="build_$PYTAG"
  rm -rf "${BUILD_DIR}"

  #EXE=$(find "${PYBIN}" -type f -name "python")
  #INC=$(find "${PYROOT}" -type f -name "Python.h" -exec dirname {} +)
  #LIB="${PYROOT}/lib"
  cmake -S. "-B${BUILD_DIR}" \
    -DPython_FIND_VIRTUALENV=ONLY

    #-DPython_EXECUTABLE="${EXE}" \
    #-DPython_INCLUDE_DIR="${INC}" \
    #-DPython_LIBRARY="${PYROOT}/lib" \
    #-DPython_ROOT_DIR="${PYROOT}/bin" \

  cmake --build "${BUILD_DIR}" -v

  # Restore environment
  deactivate
done
