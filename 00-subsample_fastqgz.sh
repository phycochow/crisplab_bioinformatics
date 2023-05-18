#!/bin/bash
#SBATCH --job-name=subsample_fastqgz
#SBATCH --array=1-54
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=15G
#SBATCH --time=8:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp
#SBATCH --requeue

usage="USAGE:
sbatch 00-subsample_fastqgz.sh <fastq_directory> <percentage>"

echo "==================== Setup ===================="

# Check if the number of arguments is correct
if [ $# -lt 2 ]; then
    echo "$usage"
    exit 1
fi

# Get the directories from the command-line argument
fastq_directory=$1
percentage=$2

# Set file paths
path_to_seqtk=/home/s4669612/software/seqtk/seqtk
path_to_working_directory=$(pwd)
path_to_raw_reads="$path_to_working_directory"/../raw_reads_template

echo "==================== Run ===================="

# Step 1 - Copy the fastq.gz files from raw_reads_template to the fastq directory
file_paths=("$path_to_raw_reads"/*)
file_path=${file_paths[$SLURM_ARRAY_TASK_ID-1]}
gz_file=$(basename "$file_path")

echo "Copying file: $gz_file to $fastq_directory"

# Step 2 - Subsample and uncompress the fastq.gz files, store as .fastq
echo "Subsampling $gz_file with percentage: $percentage"
"$path_to_seqtk" sample -s100 "$file_path" "$percentage" > "$fastq_directory"/"${gz_file%.gz}"

echo "Subsampling complete for $gz_file"

