#!/bin/bash

#SBATCH --job-name=trim_galore_gz_sbatch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=06:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

set -xeuo pipefail

usage="USAGE:
bash 01-trim_galore_sbatch.sh <sample_list.txt> <walltime> <memory> <account_department> <fastq_dir>"

# Define step in the pipeline - should be the same name as the script
step="01-trim_galore_gz"

######### Setup ################
sample_list="$1"
walltime="$2"
mem="$3"
account_department="$4"
fastq_dir="$5"

if [ "$#" -lt 5 ]; then
  echo "$usage"
  exit -1
else
  echo "Submitting samples listed in '$sample_list' for trimming"
  cat "$sample_list"
fi

# Number of samples
number_of_samples=$(wc -l "$sample_list" | awk '{print $1}')
if [[ "$number_of_samples" -eq 1 ]]; then
  sbatch_t=1
else
  sbatch_t="1-${number_of_samples}"
fi
echo "Argument to be passed to sbatch -t is '$sbatch_t'"

########## Run #################

# Make log and analysis folders
# Make logs folder if it doesn't exist yet
mkdir -p logs

timestamp=$(date +%Y%m%d-%H%M%S)

# Make analysis dir if it doesn't exist yet
analysis_dir="analysis"
mkdir -p "$analysis_dir"

# Make trimmgalore logs folder, timestamped
log_folder="logs/${timestamp}_${step}"
mkdir "$log_folder"

# Script path and cat a record of what was run
script_dir=~/gitrepos/crisplab_wgs
script_to_sbatch="${script_dir}/${step}.sh"
cat "$script_to_sbatch" > "${log_folder}/script.log"
cat "$0" > "${log_folder}/sbatch_runner.log"

# Submit sbatch and pass args
# -o and -e pass the file locations for std out/error
# --export additional variables to pass to the sbatch script including the array list and the dir structures
sbatch_output=$(sbatch --array "$sbatch_t" \
  -t "$walltime" \
  -N 1 \
  -n 1 \
  --cpus-per-task 2 \
  --mem-per-cpu "${mem}G" \
  -o "${log_folder}/${step}_o_%A_%a" \
  -e "${log_folder}/${step}_e_%A_%a" \
  --export "LIST=${sample_list},FASTQ_DIR=${fastq_dir}" \
  --account "$account_department" \
  "$script_to_sbatch")

# Extract the job ID from sbatch output, and keep running until all sub-jobs are completed
job_id=$(echo "$sbatch_output" | awk '{print $4}')
while [[ $(squeue -h -j "$job_id" -t PD,R) ]]; do
  sleep 90
done
echo "All jobs completed."
