#!/bin/bash
#SBATCH --job-name=make
#SBATCH --cpus-per-task=48
#SBATCH --time=06:30:00
#SBATCH -o /data/mfulghieri/enzo-dev/outputs/compilation/Make_CondaMachibe.out
#SBATCH -e /data/mfulghieri/enzo-dev/outputs/compilation/Make_CondaMachine.err


echo "Starting Enzo make: $(date) on $(hostname)..."

cd /data/mfulghieri/enzo-dev/src/enzo

make clean

make -j 30 machine-conda

make

echo "End Enzo make: $(date) on $(hostname)"


# Compiled with opt-debug (OPT_FLAGS = -g). May run much faster while still accurate with make opt-high (OPT_FLAGS = -O2)