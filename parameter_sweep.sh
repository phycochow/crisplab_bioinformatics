#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

# Define the percentages for subsampling
percentages=(1)
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/pipeline.sh

# Loop over each percentage and process the files, the random seed -s100 is to ensure the subsampling works on the paired reads, it should work with any number
for percentage in "${percentages[@]}"; do
# Copy the raw_reads into the temporary read folder to be processed
  for file in ../../raw_reads/*; do
    cp "$file" ../inputs/reads
    /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "${file%.fastq.gz}.fastq"
  done
  
# Delete all compressed files
  for file in ../../raw_reads/*.fastq.gz; do
      rm "$file"
  done
  
  run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script")
done
