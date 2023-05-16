#!/bin/bash -l
#SBATCH --job-name trim_galore_gz
#SBATCH --requeue
#SBATCH --partition=general

########## QC #################
set -xeuo pipefail

echo ------------------------------------------------------
echo SBATCH: working directory is $SLURM_SUBMIT_DIR
echo SBATCH: job identifier is $SLURM_JOBID
echo SBATCH: array_ID is ${SLURM_ARRAY_TASK_ID}
echo ------------------------------------------------------

echo working dir is $PWD

#cd into work dir
echo changing to SLURM_SUBMIT_DIR
cd "$SLURM_SUBMIT_DIR"
echo working dir is now $PWD

########## Modules #################

module load fastqc/0.11.9-java-11
module load cutadapt/3.4-gcccore-10.3.0

########## Set up dirs #################

#get job ID
#use sed, -n supression pattern space, then 'p' to print item number {SLURM_ARRAY_TASK_ID} eg 2 from {list}
ID="$(/bin/sed -n ${SLURM_ARRAY_TASK_ID}p ${LIST})"

#make trimmed folder
trimmedfolder=analysis/trimmed
mkdir -p $trimmedfolder

fastqcfolder=analysis/fastqc
mkdir -p $fastqcfolder

# check if single or paired end or unzipped by looking for R2 file
if [ -e "${FASTQ_DIR}/${ID}_R2*.fastq" ] || [ -e "${FASTQ_DIR}/reads/${ID}_R2.fastq" ]; then

echo "paired reads"

########## Run #################
# for swift libraries this trimms 20bp from the 5' end of the R2 read to remove the adaptase tail.
# Swift recommends symetrical trimming, so I trim from the R1 read too...

trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder --paired ${FASTQ_DIR}/${ID}_R1*fastq ${FASTQ_DIR}/${ID}_R2*fastq

# check if single or paired end or unzipped by looking for R2 file
elif [ -e "${FASTQ_DIR}/reads/${ID}_R2_001.fastq" ] || [ -e "/"${FASTQ_DIR}/${ID}_R2*.fastq"" ]; then

echo "paired reads uncompressed"

########## Run #################
# for swift libraries this trimms 20bp from the 5' end of the R2 read to remove the adaptase tail.
# Swift recommends symetrical trimming, so I trim from the R1 read too...

trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder --paired ${FASTQ_DIR}/reads/${ID}_R1*fastq ${FASTQ_DIR}/reads/${ID}_R2*fastq


elif [ -e "${FASTQ_DIR}/${ID}_R1_001.fastq" ] || [ -e "${FASTQ_DIR}/${ID}_R1.fastq" ]; then
  # single end compressed
  ########## Run #################
  # for swift libraries this trimms 20bp from the 5' end of the R2 read to remove the adaptase tail.
  # Swift recommends symetrical trimming, so I trim from the R1 read too...

  trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder ${FASTQ_DIR}/${ID}_R1*fastq

else
echo "assuming single end uncompresed"

########## Run #################
# for swift libraries this trimms 20bp from the 5' end of the R2 read to remove the adaptase tail.
# Swift recommends symetrical trimming, so I trim from the R1 read too...

trim_galore --phred33 --fastqc --fastqc_args "--noextract --outdir $fastqcfolder" -o $trimmedfolder /scratch/project/crisp008/chris/NGS_project/inputs/reads/${ID}_R1*fastq

#compress original reads again
# gzip ${FASTQ_DIR}/${ID}_R1_001.fastq

fi

echo Done trimming
