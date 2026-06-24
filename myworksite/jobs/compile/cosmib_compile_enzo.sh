#!/bin/bash
#SBATCH --job-name=enzo_compile
#SBATCH --cpus-per-task=48
#SBATCH --time=03:30:00
#SBATCH -o /data/mfulghieri/enzo-dev/outputs/compilation/Cosmib_compilation.out
#SBATCH -e /data/mfulghieri/enzo-dev/outputs/compilation/Cosmib_compilation.err


module purge

# Environment
source /data/mfulghieri/anaconda3/etc/profile.d/conda.sh   # Initialize conda for bash
eval "$(conda shell.bash hook)"                            
conda activate enzo                                      
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to activate Conda environment 'enzo'. Aborting." >&2
    exit 1
fi

echo " Environment configured successfully. Starting the compilation..."


# Load compiler and hdf5 mpi-optimized for the cluster
module load gcc-11.3.0/ompi-4.1.4_nccl gcc-11.3.0/hdf5-1.14.4-2-ompi

# Export the OpenMPI wrapper environment variables to point to the host compilers (/usr/bin/gcc, /usr/bin/g++, /usr/bin/gfortran). 
# Even when Conda is activated and prepends its own bin directory to PATH, OpenMPI's wrappers will use the host compilers 
export OMPI_CC=/usr/bin/gcc
export OMPI_CXX=/usr/bin/g++
export OMPI_FC=/usr/bin/gfortran

cd /data/mfulghieri/enzo-dev/src/enzo

# Write the Make.config, module setting
make grackle-no
make hypre-no
make papi-no
make libyt-no

# Clean old compilations
make clean

# Rename Make.mach.cosmib into the extensionless Make.mach
make machine-cosmib

# Show make configuration
echo "Current Enzo configuration:"
echo " "
make show-config
echo " "

# Launch compilation, make reads the extensionless Make.mach
echo " "
echo "Launching compilation...:"
echo " "

make -j 48

