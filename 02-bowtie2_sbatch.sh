#!/bin/bash
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
# for file in "$fastq_directory"/*; do
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
sbatch --array $sbatch_t \
-t ${walltime} \
-N 1 \
-n 1 \
--cpus-per-task ${bt2_threads} \
--mem ${mem}gb \
-o ${log_folder}/${step}_o_%A_%a \
-e ${log_folder}/${step}_e_%A_%a \
--export LIST=${sample_list},reads_folder=$reads_folder,bt2_threads=$bt2_threads,bt2_genome=$bt2_genome,q10filter=$q10filter \
--account $account_department \
$script_to_sbatch


