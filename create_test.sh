#!/bin/bash

function escape_path()
{
    echo $1 | sed -e 's/\//\\\//g'
}

clear_from_shell()
{
    if [ -z "$1" ]; then
	return
    fi
    TMP=`basename "$1"`
    if [ "$2" != "*" ]; then
        TMP=${TMP##$2}
    fi
    echo ${TMP%$3}
}

print_variants() 
{
    if [ "$#" -lt 2 ]; then
	return
    fi
    out=""
    for i in `ls ./$1/*`; do
	if [ "$2" = "shell" ]; then
	    file=`clear_from_shell $i "env_" "\.sh"`
	elif [ "$2" = "c" ]; then
	    file=`clear_from_shell $i "*" "\.c"`
	fi
	out="$out $file"
    done
    echo "$out"
}

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <mpi-type> <mpirun/pmi> <prog>"
    echo "	<mpi-type>: "`print_variants mpi shell`
    echo "	<prog>: "`print_variants progdir c`
    echo "Available dmtcp types:: "`print_variants dmtcp shell`
    exit 0
fi

mpi=$1
pm=$2
prog=$3

mpi_ok=0
for i in `print_variants mpi shell`; do
    if [ "$i" = $mpi ]; then
	mpi_ok=1
    fi
done
if [ "$mpi_ok" -eq 0 ]; then
    echo "bad mpi param"
    exit 0
fi

pm_ok=0
for i in mpirun pmi; do
    if [ "$i" = $pm ]; then
	pm_ok=1
    fi
done
if [ "$pm_ok" -eq 0 ]; then
    echo "bad mpirun/pmi param"
    exit 0
fi

prog_ok=0
for i in `print_variants progdir c`; do
    if [ "$i" = $prog ]; then
	prog_ok=1
    fi
done
if [ "$prog_ok" -eq 0 ]; then
    echo "bad prog param"
    exit 0
fi

CLEANDIR=./testdir/$mpi/$pm/$prog/clear/
MPIENV=`pwd`"/mpi/env_$mpi.sh"
MPIENV_ESC=`escape_path $MPIENV`


mkdir -p $CLEANDIR
cat ./templates/clear_$pm.job \
    | sed -e "s/@MPI_ENV@/$MPIENV_ESC/g" \
    | sed -e "s/@SLURMVAR@/$DMTCPENV_ESC/g" > $CLEANDIR/slurm.job


. $MPIENV
LINKING=""
if [ "$pm" = "pmi" ]; then
    LINKING=$LINKING" "$PMI_LINK
fi
mpicc -o $CLEANDIR/binary -g -O0 ./progdir/$prog.c $LINKING


for dmtcp in `print_variants dmtcp shell`; do
    DMTCPDIR=./testdir/$mpi/$pm/$prog/$dmtcp
    MPIENV=`pwd`"/mpi/env_$mpi.sh"
    MPIENV_ESC=`escape_path $MPIENV`
    DMTCPENV=`pwd`"/dmtcp/env_$dmtcp.sh"
    DMTCPENV_ESC=`escape_path $DMTCPENV`

    mkdir -p $DMTCPDIR
    cat ./templates/slurm_ckpt_$pm.job \
        | sed -e "s/@MPI_ENV@/$MPIENV_ESC/g" \
        | sed -e "s/@DMTCP_ENV@/$DMTCPENV_ESC/g" > $DMTCPDIR/slurm_ckpt.job
    
    cat ./templates/slurm_rstr.job \
        | sed -e "s/@MPI_ENV@/$MPIENV_ESC/g" \
        | sed -e "s/@DMTCP_ENV@/$DMTCPENV_ESC/g" > $DMTCPDIR/slurm_rstr.job
    
    mpicc -o $DMTCPDIR/binary -g -O0 ./progdir/$prog.c $LINKING
done

