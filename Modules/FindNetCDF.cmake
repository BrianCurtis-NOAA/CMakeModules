find_library(netcdfc
        NAMES libnetcdf.a
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{NetCDF_ROOT}/lib"
        )
message(STATUS "Found NetCDF-C: ${netcdfc}")

find_path(netcdf_include
        NAMES netcdf.h
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{NetCDF_ROOT}/include"
        )
message(STATUS "Found netcdf.h: ${netcdf_include}")

find_library(netcdff
        NAMES libnetcdff.a
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{NetCDF_ROOT}/lib"
        )
message(STATUS "Found NetCDF Fortran: ${netcdff}")

find_library(hdf5
        NAMES libhdf5.a
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{HDF5_ROOT}/lib"
        )
message(STATUS "Found HDF5: ${hdf5}")

find_library(hdf5_hl
        NAMES libhdf5_hl.a
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{HDF5_ROOT}/lib"
        )
message(STATUS "Found HDF5-HL: ${hdf5_hl}")

find_library(compression
        NAMES libz.a libsz.a
        REQUIRED
        NO_DEFAULT_PATH
        HINTS "$ENV{ZLIB_ROOT}/lib" "$ENV{SZIP_ROOT}/lib")

message(STATUS "Found Compression library: ${compression}")

    if (NOT TARGET NetCDF::NetCDF_C)
add_library(NetCDF::NetCDF_C STATIC IMPORTED)

    set_target_properties(NetCDF::NetCDF_C PROPERTIES
            IMPORTED_LOCATION ${netcdfc}
            INTERFACE_INCLUDE_DIRECTORIES ${netcdf_include})

target_link_libraries(NetCDF::NetCDF_C INTERFACE ${hdf5_hl} ${hdf5} ${compression})
endif()

if (NOT TARGET NetCDF::NetCDF_Fortran)

add_library(NetCDF::NetCDF_Fortran STATIC IMPORTED)

    set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
            IMPORTED_LOCATION ${netcdff}
            INTERFACE_INCLUDE_DIRECTORIES ${netcdf_include})

    target_link_libraries(NetCDF::NetCDF_Fortran INTERFACE NetCDF::NetCDF_C)
endif()

find_package_handle_standard_args(NetCDF
  REQUIRED_VARS netcdfc netcdff hdf5 hdf5_hl compression
)
