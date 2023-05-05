#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --array=1-4%1
#SBATCH --partition=general
#SBATCH --requeue

#SBATCH --job-name=seqtk-sample
#SBATCH --output=seqtk-sample-%j.out
#SBATCH --error=seqtk-sample-%j.err
#SBATCH --time=00:10:00
#SBATCH --mem=4G

# Define the list of numbers to use
percentages=(1 2 3 4 5)

# Loop over each number and process the files
for number in "${numbers[@]}"; do
  for file in *; do
    /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$number" | gzip > "new_${file}_$number.fastq.gz"
  done
done

