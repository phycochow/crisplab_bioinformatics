#!/bin/bash
#SBATCH --job-name=trim_galore
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=30:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

#set -xe
set -xeuo pipefail

usage="USAGE:
bash 02-bowtie1_sbatch.sh <sample_list.txt> <reads_folder> <bt2_threads> <bt2_genome.fa> <q10filter> <walltime> <mem> <account_department>"

#define stepo in the pipeline - should be the same name as the script
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
fastq_directory=$9

if [ "$#" -lt "8" ]; then
  echo $usage
  exit -1
else
  echo "initiating bowtie jobs on $reads_folder folder, bowtie can use $bt2_threads threads"
  cat $sample_list
  echo genome reference is $bt2_genome
fi

# sbatch -J only takes a range to hack - for 1 sample, create a second sample in the input list called "NULL"
number_of_samples=`wc -l $sample_list | awk '{print $1}'`
if [[ "$number_of_samples" -eq 1 ]]; then
  sbatch_t=1
else
  sbatch_t="1-${number_of_samples}"
fi

echo "argument to be passed to sbatch -J is '$sbatch_t'"

# #################################### Extra - delete untrimmed fastq files to save space ####################################
# for file in $fastq_directory; do  done in trim.sh
#   rm "$file"
# done


#################################### Run ####################################

#make logs directory if it doesnt exist yet - it should
mkdir -p logs

#make timestamped trimmgalore logs folder 
timestamp=$(date +%Y%m%d-%H%M%S)
log_folder=logs/${timestamp}_${step}
mkdir $log_folder

#script path and cat a record of what was run
script_dir=~/gitrepos/crisplab_wgs
script_to_sbatch=${script_dir}/${step}.sh
cat $script_to_sbatch > ${log_folder}/script.log
cat $0 > ${log_folder}/sbatch_runner.log

#submit sbatch and pass args
#-o and -e pass the file locations for std out/error
#--export additional variables to pass to the sbatch script including the array list and the dir structures
sbatch_output=$(sbatch --array $sbatch_t \
-t 03:00:00 \
-N 1 \
-n 1 \
--cpus-per-task ${bt2_threads} \
--mem ${mem}gb \
-o ${log_folder}/${step}_o_%A_%a \
-e ${log_folder}/${step}_e_%A_%a \
--export LIST=${sample_list},reads_folder=$reads_folder,bt2_threads=$bt2_threads,bt2_genome=$bt2_genome,q10filter=$q10filter \
--account $account_department \
$script_to_sbatch)


# Extract the job ID from sbatch output
job_id=$(echo $sbatch_output | awk '{print $4}')
while [[ $(squeue -h -j $job_id -t PD,R) ]]; do
    sleep 30
done
echo "All jobs completed."
#################################### Keep Running til Completion for Job Dependency ####################################

# # Wait for the sub-sbatch jobs to complete
# sbatch_exit_status=$(echo $job_id | awk '{print $NF}')
# if [ "$sbatch_exit_status" != "0" ]; then
#   echo "Error submitting the sub-sbatch jobs. Exiting."
#   exit 1
# fi

# sbatch_job_id=$(echo $job_id | awk '{print $NF}')
# echo "Submitted sub-sbatch job with ID: $sbatch_job_id"

# # Check the status of the sub-sbatch job and wait until it completes
# while true; do
#   job_status=$(squeue -j $sbatch_job_id -h -t PD,R,CG,CA,CF | wc -l)
#   if [ "$job_status" -eq 0 ]; then
#     echo "Sub-sbatch job ($sbatch_job_id) completed successfully."
#   break
#   fi
#   sleep 10
# done
