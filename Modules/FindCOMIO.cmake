# FindCOMIO.cmake
#
# Copyright NOAA/NWS/NCEP/SWPC 2023
#
# Components available for query:
#  Fortran - Has Fortran support
#  STATIC - Has static targets
#
# Variables provided:
#  COMIO_FOUND - True if COMIO was found
#  COMIO_Fortran_FOUND - True if COMIO Fortran support was found
#  COMIO_VERSION - Version of installed COMIO
#
# Targets provided:
#  COMIO::COMIO_Fortran - Fortran interface target aliases to SHARED|STATIC as requested or to shared libraries if available else static libraries
#
# To control finding of this package, set COMIO_ROOT environment variable to the full path to the prefix
# under which COMIO was installed (e.g., /usr/local)

set( _search_components )
set( _search_library_type )
foreach( _comp ${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS} )
    if( _comp MATCHES "^(STATIC|SHARED)$" )
        list( APPEND _search_library_type ${_comp} )
    else()
        list( APPEND _search_components ${_comp} )
    endif()
endforeach()
set( ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS ${_search_components} )

# If no COMPONENTS are requested, seach both C and Fortran
if( NOT _search_components )
    list( APPEND _search_components C Fortran )
endif()

# Ensure there is only one type of library being requested
if( _search_library_type )
    list( LENGTH _search_library_type _len)
    if( _len GREATER 1 )
        message(FATAL_ERROR "User requesting both STATIC and SHARED is not permissible")
    endif()
    unset(_len)
endif()

## Find libraries and paths, and determine found components
find_path(COMIO_INCLUDE_DIR NAMES comio.mod HINTS "${COMIO_PREFIX}" PATH_SUFFIXES include include/comio)
if(COMIO_INCLUDE_DIR)
    string(REGEX REPLACE "/include(/.+)?" "" COMIO_PREFIX ${COMIO_INCLUDE_DIR})
    set(COMIO_PREFIX ${COMIO_PREFIX} CACHE STRING "")
    find_path(COMIO_MODULE_DIR NAMES comio.mod PATHS "${COMIO_PREFIX}"
              PATH_SUFFIXES include include/comio lib/comio/module module module/comio NO_DEFAULT_PATH)
    if(APPLE)
      set(_SHARED_LIB_EXT dylib)
    else()
      set(_SHARED_LIB_EXT so)
    endif()
    find_library(COMIO_Fortran_STATIC_LIB libcomiof.a PATHS "${COMIO_PREFIX}" PATH_SUFFIXES lib lib64 NO_DEFAULT_PATH)
    unset(_SHARED_LIB_EXT)
    #Check for Fortran components
    if(COMIO_MODULE_DIR)
        if(COMIO_Fortran_STATIC_LIB)
            set(COMIO_Fortran_STATIC_FOUND 1)
        endif()
    endif()

    #Set version using installed .settings file
    file(READ "${COMIO_PREFIX}/bin/comio-config" ver)
    string(REGEX MATCH "version=\"comio ([0-9]*).([0-9]*).([0-9]*)" _ ${ver})
    set(COMIO_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")

endif()
## Debugging output
message(DEBUG "[FindCOMIO] COMIO_INCLUDE_DIR: ${COMIO_INCLUDE_DIR}")
message(DEBUG "[FindCOMIO] COMIO_PREFIX: ${COMIO_PREFIX}")
message(DEBUG "[FindCOMIO] COMIO_MODULE_DIR: ${COMIO_MODULE_DIR}")
message(DEBUG "[FindCOMIO] COMIO_Fortran_STATIC_LIB: ${COMIO_Fortran_STATIC_LIB}")
message(DEBUG "[FindCOMIO] COMIO_Fortran_STATIC_FOUND: ${COMIO_Fortran_STATIC_FOUND}")

## Create targets
set(_new_components)
# COMIO_Fortran_STATIC imported interface target
if(COMIO_Fortran_STATIC_FOUND AND NOT TARGET COMIO_Fortran_STATIC)
    add_library(COMIO_Fortran_STATIC INTERFACE IMPORTED)
    set_target_properties(COMIO_Fortran_STATIC PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${COMIO_INCLUDE_DIR}
        INTERFACE_LINK_LIBRARIES ${COMIO_Fortran_STATIC_LIB}
                          IMPORTED_GLOBAL True )
    if(COMIO_MODULE_DIR AND NOT COMIO_MODULE_DIR STREQUAL COMIO_INCLUDE_DIR )
        set_property(TARGET COMIO_Fortran_STATIC APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${COMIO_MODULE_DIR})
    endif()
    set(_new_components 1)
    target_link_libraries(COMIO_Fortran_STATIC INTERFACE COMIO_C_STATIC)
endif()

if( _search_library_type MATCHES "^(STATIC)$" )
    if( TARGET COMIO_Fortran_STATIC )
        add_library(COMIO::COMIO_Fortran ALIAS COMIO_Fortran_STATIC)
        set(COMIO_Fortran_FOUND 1)
    endif()
else()
    if( TARGET COMIO_Fortran_STATIC )
        add_library(COMIO::COMIO_Fortran ALIAS COMIO_Fortran_STATIC)
        set(COMIO_Fortran_FOUND 1)
    endif()
endif()

## Check package has been found correctly
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    COMIO
      REQUIRED_VARS
        COMIO_PREFIX
        COMIO_INCLUDE_DIR
        VERSION_VAR COMIO_VERSION
        HANDLE_COMPONENTS
)
message(DEBUG "[FindCOMIO] COMIO_FOUND: ${COMIO_FOUND}")

## Print status
if(${CMAKE_FIND_PACKAGE_NAME}_FOUND AND NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY AND _new_components)
    message( STATUS "Find${CMAKE_FIND_PACKAGE_NAME}:" )
    message( STATUS "  - ${CMAKE_FIND_PACKAGE_NAME}_PREFIX [${${CMAKE_FIND_PACKAGE_NAME}_PREFIX}]")
    message( STATUS "  - ${CMAKE_FIND_PACKAGE_NAME}_VERSION: [${${CMAKE_FIND_PACKAGE_NAME}_VERSION}]")
    set(_found_comps)
    foreach( _comp ${_search_components} )
        if( ${CMAKE_FIND_PACKAGE_NAME}_${_comp}_FOUND )
            list(APPEND _found_comps ${_comp})
        endif()
    endforeach()
    message( STATUS "  - ${CMAKE_FIND_PACKAGE_NAME} Components Found: ${_found_comps}")
    unset(_found_comps)
endif()
unset(_new_components)
unset(_search_components)
unset(_search_library_type)
unset(_library_type)
