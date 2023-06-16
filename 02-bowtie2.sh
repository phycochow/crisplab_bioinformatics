#!/bin/bash
#SBATCH --job-name bowtie2
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

module load bowtie2/2.4.5-gcc-11.3.0
module load samtools/1.13-gcc-10.3.0

########## Set up dirs #################
#get job ID, use sed, -n supression pattern space, then 'p' to print item number {PBS_ARRAYID} eg 2 from {list}
ID="$(/bin/sed -n ${SLURM_ARRAY_TASK_ID}p ${LIST})"
echo sample being mapped is $ID

cd analysis

# Make adaligned folder bowtie2 (caution this will not fail if dir already exists), read_folder is an environmental variable defined in sbatch
outdir="${reads_folder}_align_bowtie2"
mkdir -p ${outdir}

# output structure
outsam="${outdir}/${ID}.sam"
tmpbam="${outdir}/${ID}.bam"
outbam="${outdir}/${ID}_sorted.bam"

########## Run #################
fq_1=$(find ${reads_folder} -name "${ID}_R1*.fq" -type f)
fq_2=$(find ${reads_folder} -name "${ID}_R2*.fq" -type f)

if [[ -n "$fq_1" && -n "$fq_2" ]]; then
  echo "Paired reads"
  bowtie2 \
    -x $bt2_genome \
    --phred33 \
    --local \
    --very-sensitive-local \
    -X 2000 \
    -p $bt2_threads \
    -1 $fq_1 \
    -2 $fq_2 \
    -S "$outsam"
  
elif [[ -n "$R1_file" ]]; then
  echo "Single end, this is not tested if it works"
  bowtie2 \
    -x $bt2_genome \
    --phred33 \
    --local \
    --very-sensitive-local \
    -X 2000 \
    -p $bt2_threads \
    -1 $fq_1 \
    -S "$outsam"
fi

#################### Sort and Index ####################
# Count total alignments before after filtering
echo "${ID} total alignments before MAPQ filter (might include reads that map to multiple locations)"
samtools view -c ${outsam}

samtools view -q $q10filter -b -@ $bt2_threads $outsam | samtools sort -m 8G -@ $bt2_threads -o $outbam

#Make an index of the sorted bam file
samtools index ${outbam}

# Count total reads after filtering
echo "${ID} total alignments after MAPQ filter (should only include reads that map to one location)"
samtools view -c $outbam

# Delete the temporary sam.
rm -v ${outsam} $fq_1 $fq_2

#################### Pete's comments on Bowtie 2 ####################
# For reads longer than about 50 bp Bowtie 2 is generally faster, more sensitive, and uses less memory than Bowtie 1.
# For relatively short reads (e.g. less than 50 bp) Bowtie 1 is sometimes faster and/or more sensitive.

# Bowtie 2 supports local alignment, which doesn't require reads to align end-to-end.
# Local alignments might be "trimmed" ("soft clipped") at one or both extremes in a way that optimizes alignment score.
# Bowtie 2 also supports end-to-end alignment which, like Bowtie 1, requires that the read align entirely.

#-x bowtie index
#--phred33
#--end-to-end dont trim reads to enable alignment
# --local allows soft clipping
#--mm memory-mapped I/O to load index allow multiple processes to use index
#-p number of threds to use
#-U fastq file path, and specifies reads are not paired
#-S file to write SAM alignemnts too (although default is stdout anyhow)
#-D and -R tell bowtie to try a little harder than normal to find alignments
#-L reduce substring length to 10 (default 22) as these are short reads
#-i reduce substring interval? more sensitive?
#-N max # mismatches in seed alignment; can be 0 or 1 (0)
#-D give up extending after <int> failed extends in a row (15)
# -k report N mapping locations
# --score-min L,0,0 sets formular for min aln score for alignment to be reported, eg readlength 36 * -0.6 + -0.6) = min 0; this means only report exact matches
# Bowtie 2 does not "find" alignments in any specific order,
# so for reads that have more than N distinct, valid alignments,
# Bowtie 2 does not guarantee that the N alignments reported are the best possible in terms of alignment score.
# Still, this mode can be effective and fast in situations where the user cares more about whether a read aligns
# (or aligns a certain number of times) than where exactly it originated.

#################### Pete's comments - sort and index ####################
# In Bowtie2, a read that aligns to more than 1 site equally well is never given higher than a MAPQ of 1
# (even if it aligns to only 2 sites equally well as discussed above).
# use mapq 10 recommended for most purposes
# if you want multialigning reads you will have lower this
