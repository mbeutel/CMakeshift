
#.rst:
# FindSphinx
# ----------
#
# Find the Sphinx documentation generator.
#
# This will define the following variables::
#
#   Sphinx_FOUND      - True if Sphinx was found
#   Sphinx_EXECUTABLE - Path to the Sphinx executable


#Look for an executable called sphinx-build
find_program(Sphinx_EXECUTABLE
    NAMES sphinx-build
    DOC "Path to sphinx-build executable")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Sphinx
    REQUIRED_VARS Sphinx_EXECUTABLE
    FAIL_MESSAGE "Failed to find sphinx-build executable")

mark_as_advanced(Sphinx_EXECUTABLE)
