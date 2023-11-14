from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy
import os

__version__ = "1.1.4"

# define the extension module
pyx_files = [
    "sstmap/sstmap_ext_stef/_sstmap_ext.pyx",
]
extensions = [
    Extension(
        name=os.path.dirname(ext).replace("/", "."),
        sources=[ext],
        include_dirs=[numpy.get_include()],
        language="c++",
        extra_compile_args=["-O3"],
        # extra_link_args=["-fopenmp"],
    )
    for ext in pyx_files
]
extensions.append(
    Extension(
        "_sstmap_ext",
        sources=["sstmap/_sstmap_ext.c"],
        include_dirs=[numpy.get_include()],
        extra_link_args=["-lgsl", "-lgslcblas"],
        extra_compile_args=["-g"],
    )
)
extensions.append(
    Extension(
        "_sstmap_entropy",
        sources=["sstmap/_sstmap_entropy.cpp", "sstmap/kdhsa102.cpp"],
        include_dirs=["sstmap/"],
        language="c++",
        extra_compile_args=["-g"],
    )
)

extensions.append(
    Extension(
        "_sstmap_probableconfig",
        sources=["sstmap/_sstmap_probable.cpp", "sstmap/probable.cpp"],
        language="c++",
        extra_compile_args=["-g"],
    )
)

setup(
    version=__version__,
    zip_safe=False,
    ext_modules=extensions,
)
