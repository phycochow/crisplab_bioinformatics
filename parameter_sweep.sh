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

# Loop over each percentage and process the files, the random seed -s100 is to ensure the subsampling works on the paired reads, it should work with any number
for percentage in "${percentages[@]}"; do
  cp -r ../../raw_reads ../inputs/reads
  for file in ../inputs/reads/*; do
    /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "$file"
  done
done

bash /home/s4669612/gitrepos/crisplab_wgs/run_pipeline.sh
