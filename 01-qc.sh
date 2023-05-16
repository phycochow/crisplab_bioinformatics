#!/bin/bash
#SBATCH --job-name fastqc
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

########## Set up dirs #################

#get job ID
#use sed, -n supression pattern space, then 'p' to print item number {PBS_ARRAYID} eg 2 from {list}
ID="$(/bin/sed -n ${SLURM_ARRAY_TASK_ID}p ${LIST})"

fastqcfolder=analysis/fastqc_raw
mkdir -p $fastqcfolder

# check how many fastqs there are - assumes "fastq" suffix
fastqs="$(find ${FASTQ_DIR} -type f -name ${ID}*.fastq*)"
# convert to array to count elements
fastqs_count=($fastqs)

# check if single or paired end by looking for R2 file
if (( "${#fastqs_count[@]}" == 2 )); then
  echo "paired reads"

  ########## Run #################
  fastqc -o $fastqcfolder ${FASTQ_DIR}/${ID}_R1*.fastq ${FASTQ_DIR}/${ID}_R2*.fastq
else
  echo "assuming single end"

  ########## Run #################
  fastqc -o $fastqcfolder ${FASTQ_DIR}/${ID}_R1*.fastq
fi

echo Done QC. Now you should run multiqc in the output directory to summarize.
