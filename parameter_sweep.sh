#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --array=1-4%1
#SBATCH --partition=general
#SBATCH --requeue
#SBATCH --error=seqtk-sample-%j.err

# Define the percentages for subsampling
percentages=(1)
working_dir=/scratch/project/crisp008/chris/NGS_project/processing

# Loop over each percentage and process the files, the random seed -s100 is to ensure the subsampling works on the paired reads, it should work with any number
for percentage in "${percentages[@]}"; do
# Copy the raw_reads into the temporary read folder to be processed
  cd $working_dir
  cp -r ../../raw_reads ../inputs/reads
  for file in ../inputs/reads/*; do
    /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "$file"
  done
  
# Run script for each subsampled reads
  cd $working_dir
  path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/pipeline.sh
  run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script")
done
