#!/bin/bash
#SBATCH --job-name=feature_extraction
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash 05-extract_bam_features.sh <fastq_directory> <working_directory>"

######### Setup ################
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the fastq directory from the command-line argument
fastq_directory=$1
working_directory=$2

# Set file paths
path_to_update_script=/home/s4669612/gitrepos/crisplab_wgs/update_csv.py
path_to_output_csv=/scratch/project/crisp008/chris/NGS_project/outputs/output.csv
path_to_trim_tsv="$working_directory"
path_to_bowtie2_tsv="$working_directory"

# Activate conda environment
source /home/s4669612/miniconda3/bin/activate py3.7

# Define the vector list
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")

# Loop over each vector in the vector list
for vector_id in "${vector_list[@]}"; do

  # Loop over each BAM file in the trimmed_align_bowtie2 directory
  for file in analysis/trimmed_align_bowtie2/*.bam; do
    
    # Obtain corresponding trim and bowtie2 features from stat file
    sample_name=$(basename "$file" .bam)
    
    # Extract the row based on the sample name
    row1=$(grep -P "^${sample_name}\t" "$path_to_trim_tsv")
    row2=$(grep -P "^${sample_name}\t" "$path_to_bowtie2_tsv")
    
    # Check if row1 exists
    if [[ -n "$row1" ]]; then
      # Extract the values from the row and store them in separate variables
      read_count=$(echo "$row1" | awk -F'\t' '{print $2}')
      percent_reads_adapter_r1=$(echo "$row1" | awk -F'\t' '{print $3}')
      percent_reads_adapter_r2=$(echo "$row1" | awk -F'\t' '{print $4}')
      percent_bp_trimmed_r1=$(echo "$row1" | awk -F'\t' '{print $5}')
      percent_bp_trimmed_r2=$(echo "$row1" | awk -F'\t' '{print $6}')
      
    # Check if row2 exists
    if [[ -n "$row2" ]]; then
      # Extract the values from the row and store them in separate variables
      read_count=$(echo "$row2" | awk -F'\t' '{print $2}')
      percent_reads_adapter_r1=$(echo "$row2" | awk -F'\t' '{print $3}')
      percent_reads_adapter_r2=$(echo "$row2" | awk -F'\t' '{print $4}')
      percent_bp_trimmed_r1=$(echo "$row2" | awk -F'\t' '{print $5}')
      percent_bp_trimmed_r2=$(echo "$row2" | awk -F'\t' '{print $6}')
  
    # Run the feature extraction script
    python "$path_to_update_script" "$vector_id" "$file" "$path_to_output_csv"
  done
done

# Deactivate conda environment
conda deactivate

# remove files starting in the processsing directory
cd ..
rm -r "$working_directory" "$fastq_directory"
