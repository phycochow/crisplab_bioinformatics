#!/bin/bash
#SBATCH --job-name=my_pipeline
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=24:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

usage="USAGE:
bash 00-pipeline.sh <fastq_directory> <processing_directory>"

#################################### Setup ########################################
# Check if the number of arguments is correct
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the fastq directory from the command-line argument
fastq_directory=$1
processing_directory=$2

# Set file paths 
path_to_sample_list=/scratch/project/crisp008/chris/NGS_project/inputs/samples.txt
path_to_reference=/scratch/project/crisp008/chris/NGS_project/inputs/sorghum/Sbicolor_454_v3.0.1_vectors
path_to_qc_script=/home/s4669612/gitrepos/crisplab_wgs/01-qc_sbatch.sh
path_to_trim_script=/home/s4669612/gitrepos/crisplab_wgs/01-trim_galore_gz_sbatch.sh
path_to_bowtie_script=/home/s4669612/gitrepos/crisplab_wgs/02-bowtie2_sbatch.sh
path_to_feature_extraction_script=/home/s4669612/gitrepos/crisplab_wgs/05-extract_bam_features.sh

#################################### FastQC & MultiQC ####################################
# Submit the first job and get the job ID
cd "$processing_directory"
fastqc_job=$(sbatch --parsable --partition=general "$path_to_qc_script" "$path_to_sample_list" 2:00:00 8 a_crisp, "$fastq_directory")

# Run MultiQC after FastQC is done
if [[ $SLURM_ARRAY_TASK_ID == 2 ]]; then
  cd analysis/fastqc_raw
  conda activate py3.7
  multiqc .
  cd ../..
fi

#################################### Trim, Bowtie2, and Feature Extraction (with summaries)  ####################################
# Submit the second job and set its dependency on the first job
cd processing_directory
trim_galore_job=$(sbatch --parsable --partition=general --dependency=afterok:$fastqc_job "$path_to_trim_script" "$path_to_sample_list" 20:00:00 16 a_crisp)

# Submit the third job and set its dependency on the second job, modified bowtie_sbatch to delete the subsampled reads to increase space
cd processing_directory
bowtie2_job=$(sbatch --parsable --partition=general --dependency=afterok:$trim_galore_job "$path_to_bowtie_script" "$path_to_sample_list" trimmed 6 "$path_to_reference" 10 18:00:00 40 a_crisp)

# Submit the forth job and set its dependency on the third job
extract_bam_features_job=$(sbatch --parsable --partition=general --dependency=afterok:$bowtie2_job "$path_to_feature_extraction_script" "$fastq_directory" "$processing_directory")






#################################### Other previous code  ####################################

# Submit the fourth job and set its dependency on the third job
# path_to_trimmed_bowtie=/scratch/project/crisp008/chris/NGS_project/test3/analysis/trimmed_align_bowtie2
# deeptools_job=$(sbatch --parsable --dependency=afterok:$bowtie2_job /home/s4669612/gitrepos/crisplab_wgs/WGS/03b-deeptools_bigWig_sbatch.sh "$path_to_sample_list" 2:00:00 45 "$path_to_trimmed_bowtie" py3.7 a_crisp)


