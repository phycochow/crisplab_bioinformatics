#!/bin/bash
set -xeuo pipefail

usage="USAGE:
bash 01-qc_sbatch.sh <sample_list.txt> <walltime> <memory> <account_department> <fastq_dir>"

# Define step in the pipeline - should be the same name as the script
step="01-qc"

######### Setup ################
sample_list=$1
walltime=$2
mem=$3
account_department=$4
fastq_dir=$5

if [ "$#" -lt "4" ]; then
  echo "$usage"
  exit -1
else
  echo "Submitting samples listed in '$sample_list' for QC"
  cat "$sample_list"
fi

# Number of samples
# 'sbatch --array' takes a range, so we can create a second sample in the input list called "NULL" to handle single samples
number_of_samples=$(wc -l < "$sample_list")
if [[ "$number_of_samples" -eq 1 ]]; then
  sbatch_t=1
else
  sbatch_t="1-${number_of_samples}"
fi
echo "Argument to be passed to sbatch -t is '$sbatch_t'"

########## Run #################
# Create log and analysis folders if they don't exist yet
mkdir -p logs
analysis_dir="analysis"
mkdir -p "$analysis_dir"

timestamp=$(date +%Y%m%d-%H%M%S)

# Create timestamped trimmgalore logs folder
log_folder="logs/${timestamp}_${step}"
mkdir "$log_folder"

# Set script path and record what was run
script_dir=~/gitrepos/crisplab_wgs
script_to_sbatch="${script_dir}/${step}.sh"
cat "$script_to_sbatch" > "${log_folder}/script.log"
cat "$0" > "${log_folder}/sbatch_runner.log"

# Submit sbatch and pass arguments
# -o and -e specify file locations for stdout and stderr
# --export passes additional variables to the sbatch script, including the array list and directory structures
sbatch_output=$(sbatch --array "$sbatch_t" \
  -t "${walltime}" \
  -N 1 \
  -n 1 \
  --cpus-per-task 1 \
  --mem "${mem}gb" \
  -o "${log_folder}/${step}_o_%A_%a" \
  -e "${log_folder}/${step}_e_%A_%a" \
  --export LIST="${sample_list}",FASTQ_DIR="${fastq_dir}" \
  --account "$account_department" \
  "$script_to_sbatch")

# Extract the job ID from sbatch output, and keep running until all sub-jobs are completed
job_id=$(echo "$sbatch_output" | awk '{print $4}')
while [[ $(squeue -h -j "$job_id" -t PD,R) ]]; do
    sleep 35
done
echo "All jobs completed."

