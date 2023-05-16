#!/bin/bash -l
#SBATCH --job-name=trim_galore_gz
#SBATCH --requeue
#SBATCH --partition=general

########## QC #################
set -xeuo pipefail

########## Modules #################

module load fastqc/0.11.9-java-11
module load cutadapt/3.4-gcccore-10.3.0

########## Set up dirs #################

#get sample ID
# use sed, -n suppresses pattern space, then 'p' to print item number {SLURM_ARRAY_TASK_ID} e.g., 2 from {LIST}
ID="$(/bin/sed -n ${SLURM_ARRAY_TASK_ID}p ${LIST})"

# make trimmed folder
trimmedfolder=analysis/trimmed
mkdir -p $trimmedfolder

fastqcfolder=analysis/fastqc
mkdir -p $fastqcfolder

# Find the matching input files using the find command
R1_file=$(find ${FASTQ_DIR} -name "${ID}_R1*.fastq" -type f)
R2_file=$(find ${FASTQ_DIR} -name "${ID}_R2*.fastq" -type f)

if [[ -n "$R1_file" && -n "$R2_file" ]]; then
  # Run trim_galore with the found input files
  trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder --paired $R1_file $R2_file
  echo Done trimming
else
  echo "Input files not found for ID: $ID"
  echo "R1_file: $R1_file"
  echo "R2_file: $R2_file"
  echo SBATCH: working directory is $(pwd)
fi
