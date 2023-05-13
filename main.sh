#!/bin/bash
#SBATCH --job-name=main
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue
#SBATCH --array=1-6240%96  # Run in batches of 40, up to a total of 6000 times

# Path to the main script
path_to_parameter_sweep_script=/home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh

# Construct the list of percentages
percentages=($(seq 0.0009 0.01 0.9909))
sbatch --array=1-40%40 parameter_sweep.sh "${percentages[@]}" "$batch"




# Define the total number of iterations
total_iterations=6000

# Construct the list of percentages
percentages=($(seq 0.0009 0.01 0.9909))

# Loop over each batch
for (( batch=1; batch <= total_iterations; batch+=40 )); do

  # Calculate the start and end index for the current batch
  start_index=$(( batch ))
  end_index=$(( batch + 39 ))

  # Submit the job to run the parameter sweep script with the current batch of percentages
  sbatch --array=1-40%40 parameter_sweep.sh "${percentages[@]}" "$batch"

done
