#!/bin/bash 

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH -J EnzoZel
#SBATCH -p long
#SBATCH -o /data/mfulghieri/enzo-dev/outputs/amr_zeldovich/ZeldovichPancake_logs/job_%j.out
#SBATCH -e /data/mfulghieri/enzo-dev/outputs/amr_zeldovich/ZeldovichPancake_logs/job_%j.err
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=m.fulghieri@campus.unimib.it

# Useful paths
BASE_DIR="/data/mfulghieri/enzo-dev"
ENZO_EXE="${BASE_DIR}/src/enzo/enzo.exe" 
SIM_DIR="${BASE_DIR}/run/Cosmology/AMRZeldovichPancake"
OUT_DIR="${BASE_DIR}/outputs/amr_zeldovich"

# Creation of the required directories
mkdir -p "${OUT_DIR}"
mkdir -p /data/mfulghieri/enzo-dev/outputs/amr_zeldovich/ZeldovichPancake_logs

# Environment
source /data/mfulghieri/anaconda3/etc/profile.d/conda.sh   # Initialize conda for bash
eval "$(conda shell.bash hook)"                           
conda activate enzo                                       
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to activate Conda environment 'enzo'. Aborting." >&2
    exit 1
fi

echo " Environment configured successfully. Starting the simulation..."
echo "------------------------------------------------------------"     

# ONLY WHEN HYBRID (MPI + OPENMP)
# Set OpenMP environment variables based on SLURM settings
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK  # Set the number of OpenMP threads to match the allocated CPUs
#export OMP_PLACES=threads                    # Distribute threads across CPU cores
#export OMP_PROC_BIND=spread                  # Spread threads across cores to improve performance  

module purge
module load gcc-11.3.0/ompi-4.1.4_nccl
module load gcc-11.3.0/hdf5-1.14.1

echo "Start Enzo's Zel'dovich Pancake simulation: $(date) on $(hostname)"

# Remove unuseful warnings
export UCX_LOG_LEVEL=error          
export OMPI_MCA_btl=^openib 

if [ $? -ne 0 ]; then
    echo "ERROR: HPC modules failed to load. Aborting the job." >&2
    exit 1
fi

# Print some useful information 
echo "============================================================"
echo "Running on host: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Partition:  $SLURM_JOB_PARTITION"
echo "Allocated nodes: $SLURM_JOB_NODELIST"
echo "Total MPI tasks: $SLURM_NTASKS"
echo "============================================================"
echo ""

# Symobolic copy enzo.exe in the test dir
#ln -s "${ENZO_EXE}" "${SIM_DIR}"

# Change to the output directory before running the command to ensure all output files are created there
cd "${OUT_DIR}"

# Command execution
mpirun -np $SLURM_NTASKS "${ENZO_EXE}" "${SIM_DIR}/AMRZeldovichPancake.enzo"

echo "Simulation terminated at: $(date)"
