#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash parameter_sweep.sh <list_of_percentages>"

######### Setup ################
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/pipeline.sh
path_to_outputs=output.csv
# Check if the number of arguments is correct
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the list of percentages from the command-line argument
percentages=$@

# Loop over each percentage and process the files, the random seed -s100 is to ensure the subsampling works on the paired reads, it should work with any number
for percentage in "${percentages[@]}"; do
# Copy the raw_reads into the temporary read folder to be processed
  for file in ../../raw_reads/*; do
    cp "$file" ../inputs/reads
  done
  
  # Subsamples and uncompress the fastqz files
  for file in ../inputs/reads/*; do
   /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "${file%.fastq.gz}.fastq"
  done
      
  # Delete all compressed files in the new directory
  for file in ../inputs/reads/*.fastq.gz; do
      rm "$file"
  done
  
  # Run and wait for the pipeline job to complete
  run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script")
done
 
