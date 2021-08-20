find_library(netcdfc
        NAMES libnetcdf.a
        )

find_path(netcdf_include
        NAMES netcdf.h
        )

find_library(netcdff
        NAMES libnetcdff.a
        )

find_library(hdf5
        NAMES libhdf5.a
        )

find_library(hdf5_hl
        NAMES libhdf5_hl.a
        )

find_library(compression
        NAMES libz.a libsz.a)

add_library(NetCDF::NetCDF_Fortran STATIC IMPORTED)

    set_target_properties(NetCDF::NetCDF_Fortran PROPERTIES
            IMPORTED_LOCATION ${netcdff}
            INTERFACE_INCLUDE_DIRECTORIES ${netcdf_include})

target_link_libraries(NetCDF::NetCDF_Fortran ${netcdfc} ${hdf5_hl} ${hdf5} ${compression})

