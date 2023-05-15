#!/bin/bash
#SBATCH --job-name=feature_extraction
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=5:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

usage="USAGE:
bash 05-extract_bam_features.sh <fastq_directory> <processing_directory>"

#################################### Setup ########################################
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the fastq directory from the command-line argument
fastq_directory=$1
processing_directory=$2

# Set file paths
path_to_update_script=/home/s4669612/gitrepos/crisplab_wgs/update_csv.py
path_to_output_csv=/scratch/project/crisp008/chris/NGS_project/outputs/output.csv

#################################### Log Scraping Section 1 ####################################
cd "$processing_directory"/logs

# Find and enter the directory that ends with "01-trim_galore_gz"
dir=$(find . -type d -name "*01-trim_galore_gz" -print -quit)
if [[ -n "$dir" ]]; then
    cd "$dir" || exit
else
    echo "Directory ending with '01-trim_galore_gz' not found."
fi

# Generate total_reads_summary tsv
echo -e "Sample\tTotal_sequences_analysed\tPERCENT_READS_WITH_ADAPTERS_R1\tPERCENT_READS_WITH_ADAPTERS_R2\tPERCENT_BP_TRIMMED_R1\tPERCENT_BP_TRIMMED_R2" > ../total_reads_summary.tsv
for i in $(ls 01-trim_galore_gz_e*); do
  SAMPLE=$(grep '+ ID=' $i | cut -d "=" -f 2)
  TOTAL_READS=$(grep 'Total number of sequences analysed:' $i | tr -s ' ' | cut -d " " -f 6)
  PERCENT_READS_WITH_ADAPTERS=$(grep 'Reads with adapters:' $i | tr -s ' ' | cut -d " " -f 5 | paste -sd '\t')
  PERCENT_BP_TRIMMED=$(grep 'Quality-trimmed:' $i | tr -s ' ' | cut -d " " -f 4 | paste -sd '\t')
  echo -e "$SAMPLE\t$TOTAL_READS\t$PERCENT_READS_WITH_ADAPTERS\t$PERCENT_BP_TRIMMED"
done >> ../total_reads_summary.tsv

# Store trim tsv path
path_to_trim_tsv=$(pwd)/total_reads_summary.tsv

#################################### Log Scraping Section 2 ####################################
cd "$processing_directory"/logs

# Find and enter the directory that ends with "02-bowtie2"
dir=$(find . -type d -name "*02-bowtie2" -print -quit)
if [[ -n "$dir" ]]; then
    cd "$dir" || exit
else
    echo "Directory ending with '02-bowtie2' not found."
fi

# Generate bowtie2_summary tsv
echo -e "sample\tALIGNED_1_TIME\tMULTI_MAPPINGS\tUNMAPPED" > bowtie2_summary.tsv
for i in $(ls 02-bowtie2_e*); do
  SAMPLE=$(grep 'echo sample being mapped is' $i | cut -d " " -f 7)
  ALIGNED_1_TIME=$(grep ') aligned concordantly exactly 1 time' $i | cut -d " " -f 6)
  MULTI_MAPPINGS=$(grep ' aligned concordantly >1 times' $i | cut -d " " -f 6)
  UNMAPPED=$(grep ') aligned concordantly 0 times' $i | cut -d " " -f 6)
  echo -e "$SAMPLE\t$ALIGNED_1_TIME\t$MULTI_MAPPINGS\t$UNMAPPED"
done >> bowtie2_summary.tsv

# Store bowtie2 tsv path
path_to_bowtie2_tsv=$(pwd)/bowtie2_summary.tsv

#################################### Log Scraping Section 3 ####################################

# Generate bowtie2_MAPQ tsv
echo -e "sample\tTOTAL_ALIGNMENTS\tMAPQ10\tPERCENT" >MAPQ_filter_summary.tsv
for i in $(ls 02-bowtie2_o*); do
  SAMPLE=$(grep 'sample being mapped is' $i | cut -d " " -f 5)
  TOTAL_ALIGNMENTS=$(grep -A1 'total alignments before MAPQ filter' $i | grep -v "total alignments before MAPQ filter")
  MAPQ10=$(grep -A1 'total alignments after MAPQ filter' $i | grep -v "total alignments after MAPQ filter")
  if [[ "$TOTAL_ALIGNMENTS" -ne 0 ]]; then
    PERCENT=$(awk -v mapq10="$MAPQ10" -v total="$TOTAL_ALIGNMENTS" 'BEGIN { printf("%d\n", (mapq10 / total) * 100 + 0.5) }')
  else
    PERCENT=0
  fi
  echo -e "$SAMPLE\t$TOTAL_ALIGNMENTS\t$MAPQ10\t$PERCENT"
done >> MAPQ_filter_summary.tsv

# Store bowtie2_MAPQ tsv path
path_to_bowtie2_MAPQ_tsv=$(pwd)/MAPQ_filter_summary.tsv

#################################### Feature Extraction Section ####################################
# Activate conda environment
source /home/s4669612/miniconda3/bin/activate py3.7

# Define the vector list
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")

# Loop over the sample names
for sample_name in $(cat "$fastq_directory"/../samples.txt); do

  # Extract the row based on the sample name
  row1=$(grep -P "^${sample_name}\t" "$path_to_trim_tsv")
  row2=$(grep -P "^${sample_name}\t" "$path_to_bowtie2_tsv")
  row3=$(grep -P "^${sample_name}\t" "$path_to_bowtie2_MAPQ_tsv")

  # Check if row1 exists
    if [[ -n "$row1" ]]; then
    # Extract the values from the row1 and store them in separate variables
      read_count=$(echo "$row1" | awk -F'\t' '{gsub(/[\(\)]/, "", $2); print $2}')
      percent_reads_adapter_r1=$(echo "$row1" | awk -F'\t' '{gsub(/[\(\)]/, "", $3); print $3}')
      percent_reads_adapter_r2=$(echo "$row1" | awk -F'\t' '{gsub(/[\(\)]/, "", $4); print $4}')
      percent_bp_trimmed_r1=$(echo "$row1" | awk -F'\t' '{gsub(/[\(\)]/, "", $5); print $5}')
      percent_bp_trimmed_r2=$(echo "$row1" | awk -F'\t' '{gsub(/[\(\)]/, "", $6); print $6}')
    else
      read_count=0
      percent_reads_adapter_r1=0
      percent_reads_adapter_r2=0
      percent_bp_trimmed_r1=0
      percent_bp_trimmed_r2=0
    fi

    # Check if row2 exists
    if [[ -n "$row2" ]]; then
      # Extract the values from the row2 and store them in separate variables
      raligned_1_time=$(echo "$row2" | awk -F'\t' '{gsub(/[\(\)]/, "", $2); print $2}')
      multi_mappings=$(echo "$row2" | awk -F'\t' '{gsub(/[\(\)]/, "", $3); print $3}')
      unmapped=$(echo "$row2" | awk -F'\t' '{gsub(/[\(\)]/, "", $4); print $4}')
    else
      raligned_1_time=0
      multi_mappings=0
      unmapped=0
    fi
    
    # Check if row3 exists
    if [[ -n "$row3" ]]; then
      # Extract the values from the row3 and store them in separate variables
      TOTAL_ALIGNMENTS=$(echo "$row3" | awk -F'\t' '{print $2}')
      MAPQ10=$(echo "$row3" | awk -F'\t' '{print $3}')
      PERCENT=$(echo "$row3" | awk -F'\t' '{print $4}')
     else
      TOTAL_ALIGNMENTS=0
      MAPQ10=0
      PERCENT=0
    fi
    
  # Loop over each vector in the vector list
  for vector_id in "${vector_list[@]}"; do
    # Run the feature extraction script
    python "$path_to_update_script" "$vector_id" "$sample_name" "$path_to_output_csv" "$read_count" "$percent_reads_adapter_r1" "$percent_reads_adapter_r2" "$percent_bp_trimmed_r1" "$percent_bp_trimmed_r2" "$raligned_1_time" "$multi_mappings" "$unmapped" "$TOTAL_ALIGNMENTS" "$MAPQ10" "$PERCENT" 
  done
done

# Deactivate conda environment
conda deactivate

# remove the processsing and reads directory - end of the script
cd "$processing_directory"/..
rm -r "$processing_directory" "$fastq_directory"

