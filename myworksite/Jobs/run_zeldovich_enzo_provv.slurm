#!/bin/bash 

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00
#SBATCH -J EnzoZel
#SBATCH -p long
#SBATCH -o /data/mfulghieri/quokka/outputs/ZeldovichPancake_logs/job_%j.out
#SBATCH -e /data/mfulghieri/quokka/outputs/ZeldovichPancake_logs/job_%j.err
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=m.fulghieri@campus.unimib.it

# Useful paths
BASE_DIR="/data/mfulghieri/quokka"
EXE="${BASE_DIR}/build/src/problems/ZeldovichPancake/ZeldovichPancake"
INPUT="${BASE_DIR}/inputs/ZeldovichPancake.in"
#OUT_DIR="${BASE_DIR}/outputs/ZeldovichPancake_${SLURM_JOB_ID}"
OUT_DIR="${BASE_DIR}/outputs/ZeldovichPancake_not_periodic"

# Creation of the required directories
mkdir -p "${OUT_DIR}"
mkdir -p /data/mfulghieri/quokka/outputs/ZeldovichPancake_logs

# Environment
source /data/mfulghieri/anaconda3/etc/profile.d/conda.sh   # Initialize conda for bash
eval "$(conda shell.bash hook)"                            # Activate the quokka environment
conda activate quokka                                      # Activate the quokka environment, which should contain all necessary dependencies

# Set OpenMP environment variables based on SLURM settings
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK  # Set the number of OpenMP threads to match the allocated CPUs
export OMP_PLACES=threads                    # Distribute threads across CPU cores
export OMP_PROC_BIND=spread                  # Spread threads across cores to improve performance  

# exit on error 
set -e        # Exit immediately if a command exits with a non-zero status

# Execution
echo "Start Zel'dovich Pancake simulation: $(date) on $(hostname)"
echo "Resources: Tasks=1, CPUs=$SLURM_CPUS_PER_TASK"

# Print some useful information about the job
echo "Running on host: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "SLURM_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK"

# Change to the output directory before running the command to ensure all output files are created there
cd "${OUT_DIR}"

# Command execution
srun -n 1 -c $SLURM_CPUS_PER_TASK $EXE $INPUT --plotfile_prefix="$OUT_DIR/plt"

echo "Simulation terminated at: $(date)"

# commented since givees error: Slurm accounting storage is disabled
# So -> don't put before, otherwise set -e will cause the script to exit with an error when it tries to run this command
# sacct -j $SLURM_JOB_ID --format=JobID,State,Elapsed,MaxRSS





# FROM QUOKKA
#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --ntasks-per-node=16 
#SBATCH --mem=64G
#SBATCH --time=12:00:00 
#SBATCH -J DMZeldovich
#SBATCH -p long
#SBATCH -o /data/mfulghieri/quokka/outputs/DMZeldovich/DMZeldovich_logs/job_%j.out
#SBATCH -e /data/mfulghieri/quokka/outputs/DMZeldovich/DMZeldovich_logs/job_%j.err
#SBATCH --mail-type=END 
#SBATCH --mail-user=m.fulghieri@campus.unimib.it 

# Useful paths
BASE_DIR="/data/mfulghieri/quokka"
EXE="${BASE_DIR}/build/src/problems/DMZeldovich/DMZeldovich"
INPUT="${BASE_DIR}/inputs/DMZeldovich.in"



# Environment
source /data/mfulghieri/anaconda3/etc/profile.d/conda.sh   # Initialize conda for bash
eval "$(conda shell.bash hook)"                            # Activate the quokka environment
conda activate quokka                                      # Activate the quokka environment, which should contain all necessary dependencies
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to activate Conda environment 'quokka'. Aborting." >&2
    exit 1
fi

echo " Environment configured successfully. Starting the simulation..."
echo "------------------------------------------------------------"

# ONLY WHEN HYBRID (MPI + OPENMP)
# Set OpenMP environment variables based on SLURM settings
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK  # Set the number of OpenMP threads to match the allocated CPUs
#export OMP_PLACES=threads                    # Distribute threads across CPU cores
#export OMP_PROC_BIND=spread                  # Spread threads across cores to improve performance  


module load gcc-11.3.0/ompi-4.1.4_nccl
module load gcc-11.3.0/hdf5-1.14.1

if [ $? -ne 0 ]; then
    echo "ERROR: HPC modules failed to load. Aborting the job." >&2
    exit 1
fi

# Execution
echo "Start DM Zel'dovich simulation: $(date) on $(hostname)"

# Remove unuseful warnings
export UCX_LOG_LEVEL=error          
export OMPI_MCA_btl=^openib 

# Print some useful information about the 
echo "============================================================"
echo "Running on host: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Partition:  $SLURM_JOB_PARTITION"
echo "Allocated nodes: $SLURM_JOB_NODELIST"
echo "Total MPI tasks: $SLURM_NTASKS"
echo "============================================================"
echo ""


OUT_DIR="${BASE_DIR}/outputs/DMZeldovich/DMZeldovich_${SLURM_JOB_ID}"
mkdir -p "${OUT_DIR}"

# Change to the output directory before running the command to ensure all output files are created there
cd "${OUT_DIR}"

# Command execution
mpirun -np $SLURM_NTASKS $EXE $INPUT --plotfile_prefix="./plt"

echo "Simulation terminated at: $(date)"
