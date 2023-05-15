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
current_dir=$(pwd)

# Set up file paths
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh

#################################### Run ########################################
# Loop over each percentage and process the files
for percentage in "${percentages[@]}"; do

  # Store and create read and processing directories with id and percentage
  fastq_directory="inputs/reads$id"_"$percentage"
  processing_directory="processing$id"_"$percentage"
  mkdir "$fastq_directory" "$processing_directory"
  
  # Copy the raw_reads into the temporary read folder to be processed
  for file in ../raw_reads_template/; do
    cp "$file" "$fastq_directory"
  done
  
  # Subsample and uncompress the fastq files
  for file in "$fastq_directory"/*; do
    /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "${file%.fastq.gz}.fastq"
  done
      
  # Delete all compressed files in the new directory
  for file in "$fastq_directory"/*.fastq.gz; do
    rm "$file"
  done
  
  # Go into the processing directory, submit a sbatch for the pipeline job to be completed, then obtain the data
  cd "$processing_directory"
  run_pipeline_job=$(sbatch "$path_to_pipeline_script" "$fastq_directory" "$processing_directory")
done
 
