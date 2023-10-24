# (C) Copyright 2023 - NOAA-SWPC
#
# Try to find the comio headers and library
#
# This module defines:
#
#   - comio::comio    - The udunits shared library and include directory, all in a single target.
#   - COMIO_STATIC_LIB  - The library
#   - COMIO_INCLUDE_DIR - The include directory
#   - COMIO_INCLUDES - The include directory
#
# The following paths will be searched in order if set in CMake (first priority) or environment (second priority):
#
#   - COMIO_INCLUDES & COMIO_LIBRARIES - folders containing comio.mod and libcomio, respectively.
#   - COMIO_ROOT                 - root of COMIO installation
#   - COMIO_PATH                 - root of COMIO installation

find_path (
	COMIO_INCLUDES
	comio.mod
	HINTS ${COMIO_INCLUDES} $ENV{COMIO_INCLUDES}
	  ${COMIO_ROOT} $ENV{COMIO_ROOT}
	  ${COMIO_PATH} $ENV{COMIO_PATH}
	DOC "Path to comio.mod"
	)
#find_library(COMIO_STATIC_LIB
#	NAMES comio
#	HINTS ${COMIO_LIBRARIES} $ENV{COMIO_LIBRARIES}
#	  ${COMIO_ROOT} $ENV{COMIO_ROOT}
#	  ${COMIO_PATH} $ENV{COMIO_PATH}
#	DOC "Path to libcomio"
#	)

include (FindPackageHandleStandardArgs)
find_package_handle_standard_args (comio DEFAULT_MSG COMIO_INCLUDES)

mark_as_advanced (COMIO_INCLUDES)

if(COMIO_FOUND AND NOT TARGET comio::comio)
	add_library(comio::comio INTERFACE IMPORTED)
	set_target_properties(comio::comio PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${COMIO_INCLUDES})
	#	set_target_properties(comio::comio PROPERTIES INTERFACE_LINK_LIBRARIES ${COMIO_STATIC_LIB})
endif()

