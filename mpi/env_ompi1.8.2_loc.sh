#!/bin/bash

MPI_BASE=/home/polyakova/mpi/ompi-1.8.2
MPI_BIN=$MPI_BASE/bin
MPI_LIB=$MPI_BASE/lib
export PATH=$MPI_BIN:$PATH
export LD_LIBRARY_PATH=$MPI_LIB:$LD_LIBRARY_PATH

MPI_LAUNCH_BINARY=mpirun