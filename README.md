[![Manylinux2010](https://github.com/Mizux/manylinux/workflows/Manylinux2010/badge.svg)](https://github.com/Mizux/manylinux/actions?query=workflow%3AManylinux2010)
[![Linux](https://github.com/Mizux/manylinux/workflows/Linux/badge.svg)](https://github.com/Mizux/manylinux/actions?query=workflow%3ALinux)
[![MacOS](https://github.com/Mizux/manylinux/workflows/MacOS/badge.svg)](https://github.com/Mizux/manylinux/actions?query=workflow%3AMacOS)
[![Windows](https://github.com/Mizux/manylinux/workflows/Windows/badge.svg)](https://github.com/Mizux/manylinux/actions?query=workflow%3AWindows)

# Manylinux2010 vs CMake FindPython()
CMake FindPython + quay.io/pypa/manylinux2010_x86_64 image issue.

## Issue
Inside the manylinux2010 image using a `virtualenv` on any `/opt/python/*` provided, CMake fail to find the `Interpreter` **AND** the `Development` component when using the built-in
[FindPython](https://cmake.org/cmake/help/latest/module/FindPython.html) module.

note: Clic on the badge to see the log...

Manylinux may not provide the `libpython.*.so`.  
According to [PEP 513 -- A Platform Tag for Portable Linux Built Distributions](https://www.python.org/dev/peps/pep-0513/):
> Note that libpythonX.Y.so.1 is not on the list of libraries that a manylinux1 extension is allowed to link to. Explicitly linking to libpythonX.Y.so.1 is unnecessary in almost all cases: the way ELF linking works, extension modules that are loaded into the interpreter automatically get access to all of the interpreter's symbols, regardless of whether or not the extension itself is explicitly linked against libpython. Furthermore, explicit linking to libpython creates problems in the common configuration where Python is not built with --enable-shared. In particular, on Debian and Ubuntu systems, apt install pythonX.Y does not even install libpythonX.Y.so.1, meaning that any wheel that did depend on libpythonX.Y.so.1 could fail to import.

ref: https://www.python.org/dev/peps/pep-0513/#libpythonx-y-so-1

So Technically, I only need the `Python_INCLUDE_DIRS` from the `Development` component and not the `Python_LIBRARIES`...

# Protocol
Simply run the script [run.sh](run.sh) which will try to build the [docker image](Dockerfile).

Basically the Dockerfile will:
1. Starting from the pypa/manylinux2010 latest image.
2. Install a recent CMake (3.16.4).
3. Copy the [CMakeLists.txt](CMakeLists.txt) project snippet.
4. Copy the build script [build_manylinux.sh](build_manylinux.sh).
5. Run the build script i.e. `./build_manylinux.sh`.

The script [build_manylinux.sh](build_manylinux.sh) basically do:
1. For each recent Python 3 version available in `/opt/python/*`:
   1. Activate a virtualenv using this python version.
   2. Run a CMake Configure using the variable [`-DPython_FIND_VIRTUALENV=ONLY`](https://cmake.org/cmake/help/latest/module/FindPython.html#hints).
   3. Run `cmake --build`.
   4. Desactivate the virtualenv.

## Expected
The script should run without error.

## Observed
CMake can't finish the configure step...
```sh
$ /opt/python/cp35-cp35m/bin/pip install virtualenv
...
$ source venv_cp35-cp35m/bin/activate
...
$ cmake -S. -Bbuild_cp35-cp35m -DPython_FIND_VIRTUALENV=ONLY
-- The CXX compiler identification is GNU 8.3.1
-- Check for working CXX compiler: /opt/rh/devtoolset-8/root/usr/bin/c++
-- Check for working CXX compiler: /opt/rh/devtoolset-8/root/usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- project: Manylinux
-- version: 1.0
CMake Error at /usr/share/cmake-3.16/Modules/FindPackageHandleStandardArgs.cmake:146 (message):
  Could NOT find Python (missing: Python_EXECUTABLE Python_LIBRARIES
  Python_INCLUDE_DIRS Interpreter Development)
Call Stack (most recent call first):
  /usr/share/cmake-3.16/Modules/FindPackageHandleStandardArgs.cmake:393 (_FPHSA_FAILURE_MESSAGE)
  /usr/share/cmake-3.16/Modules/FindPython.cmake:347 (find_package_handle_standard_args)
  CMakeLists.txt:11 (find_package)
```

note: I we remove the `Development` component, then the script run without failure but we can't have access to the variable
`Python_INCLUDE_DIRS`...

## Investigation
`FindPython` use the code inside [Modules/FindPython/Support.cmake](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Modules/FindPython/Support.cmake) to search each components.
