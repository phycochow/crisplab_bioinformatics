#!/bin/bash
#SBATCH --job-name=subsample_fastqgz
#SBATCH --array=1-27 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=27:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

usage="USAGE:
bash 00-subsample_fastqgz.sh <fastq_directory> <percentage>

#################################### Setup ########################################
path_to_seqtk=/home/s4669612/software/seqtk/seqtk
fastq_directory=$1
percentage=$2

# Get the file to process based on the job array index
files=("$fastq_directory"/*)
file=${files[$SLURM_ARRAY_TASK_ID-1]}

# Subsample and uncompress the fastq file
"$path_to_seqtk" sample -s100 "$file" "$percentage" > "${file%.fastq.gz}.fastq"

# Delete the compressed file
rm "$file"
