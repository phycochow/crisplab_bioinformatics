#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash parameter_sweep.sh <list_of_percentages> <fastq_directory>"

######### Setup ################
# Check if the number of arguments is correct
if [ $# -lt 2 ]; then
  echo "Error: Insufficient arguments."
  echo "$usage"
  exit 1
fi

# Get the list of percentages from the command-line argument
percentages=("${@:1:$#-1}")

# Get the fastq directory from the command-line argument
fastq_directory="${@: -1}"

# Set up file paths
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/pipeline.sh
path_to_outputs=output.csv

# Loop over each percentage and process the files
for percentage in "${percentages[@]}"; do
  # Copy the raw_reads into the temporary read folder to be processed
  for file in "$fastq_directory"/*; do
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
  
  # Run and wait for the pipeline job to complete
  run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script" "$fastq_directory")
done
 
