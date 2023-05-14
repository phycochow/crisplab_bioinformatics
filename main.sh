#!/bin/bash
#SBATCH --job-name=Chris_NGS
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=96
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --array=1-9600%96  # Run in batches of 96, up to a total of 9600 times
#SBATCH --time=200:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

# Path to the main script
path_to_parameter_sweep_script=/home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh

# Construct the list of percentages - constant throughout the script
percentages=($(seq 0.0009 0.01 0.9909))

# Set the total number of job arrays
total_arrays=9600

# Path to the script for each job array
path_to_job_script=/path/to/your/job_script.sh

# Loop over the number of job arrays
for ((id=1; id<=total_arrays; id++)); do
  # Submit each job array with dependency on the previous job array
  if [[ $id -eq 1 ]]; then
    sbatch --array=1-96%96 "$path_to_parameter_sweep_script" "${percentages[@]}" "$id"
  else
    previous_array=$((id-1))
    sbatch --array=1-96%96 --dependency=afterok:$previous_array "$path_to_parameter_sweep_script" "${percentages[@]}" "$id"
  fi
done
