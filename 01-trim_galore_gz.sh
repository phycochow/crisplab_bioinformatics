#!/bin/bash -l
#SBATCH --job-name=trim_galore_gz
#SBATCH --requeue
#SBATCH --partition=general

########## QC #################
set -xeuo pipefail

echo ------------------------------------------------------
echo SBATCH: working directory is $(pwd)
echo SBATCH: job identifier is $SLURM_JOBID
echo SBATCH: array_ID is ${SLURM_ARRAY_TASK_ID}
echo ------------------------------------------------------


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

# update the command below to include the correct path for the input files
trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder --paired "${FASTQ_DIR}/${ID}_R1.fastq" "${FASTQ_DIR}/${ID}_R2.fastq"

echo Done trimming

