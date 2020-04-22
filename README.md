# Manylinux
CMake FindPython + quay.io/pypa/manylinux2010_x86_64 image issue.

## Issue
Inside the manylinux2010 image using a `virtualenv` on any `/opt/python/*` provided, CMake fail to find the `Interpreter` **AND** the `Development` component when using the built-in
[FindPython](https://cmake.org/cmake/help/latest/module/FindPython.html) module.


Manylinux may not provide the `libpython.*.so`.  
According to [PEP 513 -- A Platform Tag for Portable Linux Built Distributions](https://www.python.org/dev/peps/pep-0513/):
> Note that libpythonX.Y.so.1 is not on the list of libraries that a manylinux1 extension is allowed to link to. Explicitly linking to libpythonX.Y.so.1 is unnecessary in almost all cases: the way ELF linking works, extension modules that are loaded into the interpreter automatically get access to all of the interpreter's symbols, regardless of whether or not the extension itself is explicitly linked against libpython. Furthermore, explicit linking to libpython creates problems in the common configuration where Python is not built with --enable-shared. In particular, on Debian and Ubuntu systems, apt install pythonX.Y does not even install libpythonX.Y.so.1, meaning that any wheel that did depend on libpythonX.Y.so.1 could fail to import.

ref: https://www.python.org/dev/peps/pep-0513/#libpythonx-y-so-1

So Technically, I only need the `Python_INCLUDE_DIRS` from the `Development` component and not the `Python_LIBRARIES`...

## Investigation

`FindPython` use the code inside [Modules/FindPython/Support.cmake](https://gitlab.kitware.com/cmake/cmake/-/blob/master/Modules/FindPython/Support.cmake) to search each components.
