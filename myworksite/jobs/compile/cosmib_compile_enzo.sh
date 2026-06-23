#!/bin/bash
#SBATCH --job-name=enzo_compile
#SBATCH --cpus-per-task=48
#SBATCH --time=03:30:00
#SBATCH -o /data/mfulghieri/enzo-dev/outputs/compilation/Cosmib_compilation.out
#SBATCH -e /data/mfulghieri/enzo-dev/outputs/compilation/Cosmib_compilation.err

# Load compiler and hdf5 mpi-optimized for the cluster
module load gcc-11.3.0/ompi-4.1.4_nccl gcc-11.3.0/hdf5-1.14.4-2-ompi

cd /data/mfulghieri/enzo-dev/src/enzo

# Clean old compilations
make clean

# Rename Make.mach.cosmib into the extensionless Make.mach
make machine-cosmib

# Launch compilation, make reads the extensionless Make.mach
make -j 48

