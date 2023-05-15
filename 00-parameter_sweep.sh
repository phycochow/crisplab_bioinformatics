#!/bin/bash
#SBATCH --job-name=NGS_parameter_sweep
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=99:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

# To be run in the parent directory of processing with access to inputs and oututs
usage="USAGE:
bash 00-parameter_sweep.sh <list_of_percentages> <id>"

#################################### Setup ########################################
# Check if the number of arguments is correct
if [ $# -lt 2 ]; then
  echo "Error: Insufficient arguments."
  echo "$usage"
  exit 1
fi

# Get the list of percentages from the command-line argument
percentages=("${@:1:$#-1}")

# Get the specific id from the command-line argument e.g. 1, 2, 3... for sbatch
id="${@: -1}"

# Store current working directory
working_directory=$(pwd)

# Set up file paths
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh
path_to_subsampling_script=/home/s4669612/gitrepos/crisplab_wgs/00-subsample_fastqgz.sh

#################################### Run ########################################
# Loop over each percentage and process the files
for percentage in "${percentages[@]}"; do

  # Go/return to parent directory of inputs outputs and processing  
  cd "$working_directory"
  
  # Store and create directories with id number & respective percentage
  fastq_directory="$working_directory"/inputs/reads"$id"_"$percentage"
  processing_directory="$working_directory"/processing"$id"_"$percentage"
  mkdir "$fastq_directory" "$processing_directory"
  
  # Create subsampled fastq files
  subsampling_job=$(sbatch "$path_to_subsampling_script" "$fastq_directory" "$percentage")
    
  # Go into the processing directory, submit a sbatch for the pipeline job to be completed, then obtain the data
  cd "$processing_directory"
  mkdir analysis logs
  run_pipeline_job=$(sbatch --dependency=afterok:$subsampling_job "$path_to_pipeline_script" "$fastq_directory" "$processing_directory")
done
 
