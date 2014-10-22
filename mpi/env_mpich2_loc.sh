#!/bin/bash

#MPI_BASE=/home/polyakova/mpi/mpich-3.1.2/
MPI_BASE=/home/polyakova/mpi/mpich-3.1.2_slurm/
MPI_BIN=$MPI_BASE/bin
MPI_LIB=$MPI_BASE/lib
export PATH=$MPI_BIN:$PATH
export LD_LIBRARY_PATH=$MPI_LIB:$LD_LIBRARY_PATH

MPI_LAUNCH_BINARY=mpiexec.hydra
PMI_LINK="-lpmi"