
#.rst:
# FindSphinx
# ----------
#
# Find the Sphinx documentation generator.
#
# Look for the header file in the project's external include directory and in the system include directories.
#
# This will define the following variables::
#
#   SPHINX_FOUND      - True if Sphinx was found
#   SPHINX_EXECUTABLE - Path to the Sphinx executable


#Look for an executable called sphinx-build
find_program(SPHINX_EXECUTABLE
    NAMES sphinx-build
    DOC "Path to sphinx-build executable")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sphinx
    REQUIRED_VARS SPHINX_EXECUTABLE
    FAIL_MESSAGE "Failed to find sphinx-build executable")

mark_as_advanced(SPHINX_EXECUTABLE)
