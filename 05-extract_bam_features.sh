#!/bin/bash
#SBATCH --job-name=feature_extraction
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash 05-extract_bam_features.sh <fastq_directory>"

######### Setup ################
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the fastq directory from the command-line argument
fastq_directory=$1

# Set file paths
path_to_feature_script=/home/s4669612/gitrepos/crisplab_wgs/feature_extraction.py
path_to_output_csv=/scratch/project/crisp008/chris/NGS_project/outputs/output.csv

# Activate conda environment
source /home/s4669612/miniconda3/bin/activate py3.7

# Define the vector list
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")

# Loop over each vector in the vector list
for vector_id in "${vector_list[@]}"; do

  # Loop over each BAM file in the trimmed_align_bowtie2 directory
  for file in analysis/trimmed_align_bowtie2/*.bam; do
  
    # Run the feature extraction script
    python "$path_to_feature_script" "$vector_id" "$file" "$path_to_output_csv"
  done
done

# Deactivate conda environment
conda deactivate

# remove files starting in the processsing directory
cd ..
rm -r processing inputs/reads
