#!/bin/bash
#SBATCH --job-name=subsample_fastqgz
#SBATCH --array=1-200
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=15G
#SBATCH --time=8:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

usage="USAGE:
sbatch 00-subsample_fastqgz.sh <fastq_directory> <percentage>"

#################################### Setup ########################################
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
path_to_raw_reads=../raw_reads_template

#################################### Run ####################################
# Step 1 - Copy the fastq.gz files from raw_reads_template to the fastq directory
gz_files1=("$path_to_raw_reads"/*)
gz_file1=${gz_files1[$SLURM_ARRAY_TASK_ID-1]}
new_file="$fastq_directory"/"$gz_file1"
cp "$gz_file1" "$new_file"
echo "$new_file"

# Wait until the files are completely copied
wait

# Step 2 - Subsample and uncompress the fastq.gz files - sidenote this took me 26 HOURS to make a non-bugged version!!!
"$path_to_seqtk" sample -s100 "$new_file" "$percentage" > "${new_file%.gz}"

# Wait until the files are completely copied
# wait

# Step 3 - Delete the compressed file
# rm "$gz_file1"


