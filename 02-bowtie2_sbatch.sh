#!/bin/bash
#SBATCH --job-name=bowtie2_sbatch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=09:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

set -xeuo pipefail

usage="USAGE:
bash 02-bowtie1_sbatch.sh <sample_list.txt> <reads_folder> <bt2_threads> <bt2_genome.fa> <q10filter> <walltime> <mem> <account_department>"

#define step in the pipeline - should be the same name as the script
step=02-bowtie2

#################################### Setup ########################################
sample_list=$1
reads_folder=$2
bt2_threads=$3
bt2_genome=$4
q10filter=$5
walltime=$6
mem=$7
account_department=$8

if [ "$#" -lt "8" ]; then
  echo $usage
  exit -1
else
  echo "initiating bowtie jobs on $reads_folder folder, bowtie can use $bt2_threads threads"
  cat $sample_list
  echo "genome reference is $bt2_genome"
fi

# sbatch -J only takes a range to hack - for 1 sample, create a second sample in the input list called "NULL"
number_of_samples=$(wc -l $sample_list | awk '{print $1}')
if [[ "$number_of_samples" -eq 1 ]]; then
  sbatch_t=1
else
  sbatch_t="1-${number_of_samples}"
fi

echo "argument to be passed to sbatch -J is '$sbatch_t'"

#################################### Run ####################################
# Make logs directory if it doesn't exist yet - it should
mkdir -p logs

# Make timestamped trimmgalore logs folder 
timestamp=$(date +%Y%m%d-%H%M%S)
log_folder=logs/${timestamp}_${step}
mkdir $log_folder

# Script path and cat a record of what was run
script_dir=~/gitrepos/crisplab_wgs
script_to_sbatch=${script_dir}/${step}.sh
cat $script_to_sbatch > ${log_folder}/script.log
cat $0 > ${log_folder}/sbatch_runner.log

# Submit sbatch and pass args
# -o and -e pass the file locations for std out/error
# --export additional variables to pass to the sbatch script including the array list and the dir structures
sbatch_output=$(sbatch --array $sbatch_t \
  -t $walltime \
  -N 1 \
  -n 1 \
  --cpus-per-task ${bt2_threads} \
  --mem-per-cpu ${mem}gb \
  -o ${log_folder}/${step}_o_%A_%a \
  -e ${log_folder}/${step}_e_%A_%a \
  --export LIST=${sample_list},reads_folder=$reads_folder,bt2_threads=$bt2_threads,bt2_genome=$bt2_genome,q10filter=$q10filter \
  --account $account_department \
  $script_to_sbatch)

# Extract the job ID from sbatch output
job_id=$(echo $sbatch_output | awk '{print $4}')
while [[ $(squeue -h -j $job_id -t PD,R) ]]; do
  sleep 150
done
echo "All jobs completed."
