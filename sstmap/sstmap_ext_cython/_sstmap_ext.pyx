# cython: cdivision=True

import numpy as np
from math import sqrt
cimport numpy as np
from libcpp.vector cimport vector
from libcpp.stack cimport stack
from libcpp cimport bool
from libcpp.string cimport string
from libc.string cimport strcmp
from libc.stdio cimport printf
from libc.math cimport round, sqrt, acos, floor, fabs
from cython.parallel import prange
from cpython cimport array
import array

# We now need to fix a datatype for our arrays. I've used the variable
# DTYPE for this, which is assigned to the usual NumPy runtime
# type info object.
UINT32 = np.uint32
INT64 = np.int64
FLOAT32 = np.float32
FLOAT64 = np.float64

# "ctypedef" assigns a corresponding compile-time type to DTYPE_t. For
# every type in the numpy module there's a corresponding compile-time
# type with a _t-suffix.
ctypedef np.uint32_t UINT32_t
ctypedef np.int64_t INT64_t
ctypedef np.float32_t FLOAT32_t
ctypedef np.float64_t FLOAT64_t

import cython

            

@cython.boundscheck(False) # turn off bounds-checking for entire function
@cython.wraparound(False)  # turn off negative index wrapping for entire function
def assign_voxels(
        FLOAT32_t[:, :, :] coords,
        INT64_t[:] grid_dim,
        FLOAT64_t[:] grid_max,
        FLOAT64_t[:] grid_orig,
        INT64_t[:] wat_oxygen_ids
    ):
    cdef int i_frame, i_wat, grid_index_x, grid_index_y, grid_index_z, voxel_id
    cdef FLOAT32_t wat_x, wat_y, wat_z, wat_translated_x, wat_translated_y, wat_translated_z
    cdef int n_frames = coords.shape[0]
    cdef int n_wat = wat_oxygen_ids.shape[0]
    cdef vector[vector[int]] frame_data
    cdef vector[int] wat_data

    for i_frame in range(n_frames):
        for i_wat in range(n_wat):
            wat_id = wat_oxygen_ids[i_wat]
            wat_x = coords[i_frame, wat_id, 0]
            wat_y = coords[i_frame, wat_id, 1]
            wat_z = coords[i_frame, wat_id, 2]
            
            wat_translated_x = wat_x - grid_orig[0]
            wat_translated_y = wat_y - grid_orig[1]
            wat_translated_z = wat_z - grid_orig[2]

            if (wat_translated_x <= grid_max[0] and wat_translated_y <= grid_max[1] and wat_translated_z <= grid_max[2] 
                and wat_translated_x >= 0 and wat_translated_y >= 0 and wat_translated_z >= 0):
                grid_index_x = int(wat_translated_x/0.5)
                grid_index_y = int(wat_translated_y/0.5)
                grid_index_z = int(wat_translated_z/0.5)

                if (grid_index_x < grid_dim[0] and grid_index_y < grid_dim[1] and grid_index_z < grid_dim[2]):
                    voxel_id = (grid_index_x*grid_dim[1] + grid_index_y)*grid_dim[2] + grid_index_z
                    wat_data.clear()
                    wat_data.push_back(voxel_id)
                    wat_data.push_back(wat_id)
                    frame_data.push_back(wat_data)

    return frame_data

