#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash parameter_sweep.sh <list_of_percentages> <id>"

######### Setup ################
# Check if the number of arguments is correct
if [ $# -lt 2 ]; then
  echo "Error: Insufficient arguments."
  echo "$usage"
  exit 1
fi

# Get the list of percentages from the command-line argument
percentages=("${@:1:$#-1}")

# Get the id from the command-line argument e.g. 1, 2, 3... for sbatch
id="${@: -1}"

# Store current working directory
current_dir=$(pwd)

# Set up file paths
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh
path_to_extract_bam_features_script=/home/s4669612/gitrepos/crisplab_wgs/05-extract_bam_features.sh

# Create read and processing directories with id 
fastq_directory="inputs/reads$id"
working_directory="processing$id"

# In case this script is run directly, make reads and processing folders
mkdir -p "$fastq_directory" "$working_directory"

# Loop over each percentage and process the files
for percentage in "${percentages[@]}"; do
  # Copy the raw_reads into the temporary read folder to be processed
  for file in inputs/raw_reads_template/; do
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
  
  # Go into the processing directory, run and wait for the pipeline job to complete, then obtain the data
  cd $working_directory
  run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script" "$fastq_directory")
  extract_bam_features_job=$(sbatch --parsable --dependency=afterok:$run_pipeline_job)
done
 
