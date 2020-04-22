# manylinux
CMake + manylinux2010 image issue

Some issue while trying to use the built-in [FindPython](https://cmake.org/cmake/help/latest/module/FindPython.html) module.

Inside the manylinux2010 image cmake fail to find the `Interpreter` **AND** the `Development` component.
