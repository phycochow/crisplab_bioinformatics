#!/bin/bash
#SBATCH --job-name=trim_galore
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10G
#SBATCH --time=20:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp


#set -xe
set -xeuo pipefail

usage="USAGE:
bash 01-trim_galore_sbatch.sh <sample_list.txt> <walltime> <memory> <account_department> <fastq_dir>"

#define step in the pipeline - should be the same name as the script
step=01-trim_galore_gz

######### Setup ################
sample_list=$1
walltime=$2
mem=$3
account_department=$4
fastq_dir=$5

if [ "$#" -lt "5" ]
then
echo $usage
exit -1
else
echo "Submitting samples listed in '$sample_list' for trimming"
cat $sample_list
fi

#number of samples
number_of_samples=`wc -l $sample_list | awk '{print $1}'`
if [[ "$number_of_samples" -eq 1 ]]
then
sbatch_t=1
else
sbatch_t="1-${number_of_samples}"
fi
echo "argument to be passed to sbatch -t is '$sbatch_t'"

########## Run #################

#make log and analysis folders
#make logs folder if it doesnt exist yet
mkdir -p logs

timestamp=$(date +%Y%m%d-%H%M%S)

#make analysis dir if it doesnt exist yet
analysis_dir=analysis
mkdir -p $analysis_dir

#make trimmgalore logs folder, timestamped
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
-t $walltime \
-N 1 \
-n 1 \
--cpus-per-task 2 \
--mem-per-cpu ${mem}G \
-o ${log_folder}/${step}_o_%A_%a \
-e ${log_folder}/${step}_e_%A_%a \
--export LIST=${sample_list},FASTQ_DIR=${fastq_dir} \
--account $account_department \
$script_to_sbatch)


# Extract the job ID from sbatch output
job_id=$(echo $sbatch_output | awk '{print $4}')
while [[ $(squeue -h -j $job_id -t PD,R) ]]; do
    sleep 60
done
echo "All jobs completed."

