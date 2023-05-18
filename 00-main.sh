#!/bin/bash
#SBATCH --job-name=My_NGS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=200:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

# #set -xe
# set -xeuo pipefail
#################################### Setup ########################################
usage="USAGE:
bash 00-main.sh <working_directory>"

working_directory=$1
batch_job_statuses=()

# Path to the main script
path_to_parameter_sweep_script=/home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh
path_to_subsampling_script=/home/s4669612/gitrepos/crisplab_wgs/00-subsample_fastqgz.sh

# Construct the list of percentages - constant throughout the script
percentages=($(seq 0.01 0.01 0.03))

# Function to check if all jobs in a batch have completed
check_batch_completion() {
    local completed=1  # Assume all jobs are completed
    for job_id in "${batch_jobs[@]}"; do
        job_status=$(squeue -h -j "$job_id" -t PENDING,RUNNING,TIMEOUT,FAILED,CANCELLED | wc -l)
        if [ "$job_status" -gt 1 ]; then  # Check if there are running or pending jobs
            completed=0  # If any job is not completed, set completed to 0
            break
        fi
    done
    echo $completed
}

#################################### Run ########################################
# Specify the number of duplicates and the batch size
total_jobs=4
batch_size=2

for percentage in "${percentages[@]}"; do
    echo "Processing percentage: $percentage"

    # Loop through the job array
    for ((i=1; i<=total_jobs; i+=batch_size)); do
        echo "Processing batch: $i to $((i+batch_size-1))"

        batch_jobs=()
        echo "batch_jobs has been reset to ${batch_jobs[@]}"

        # Submit jobs for the current batch
        for ((j=i; j<i+batch_size; j++)); do
            if [ $j -le $total_jobs ]; then
                echo "Processing job: $j"

                # Go/return to parent directory of inputs outputs and processing  
                cd "$working_directory"

                # Store and create directories with id number & respective percentage
                fastq_directory="$working_directory"/inputs/reads"$j"_"$percentage"
                processing_directory="$working_directory"/processing"$j"_"$percentage"
                mkdir "$fastq_directory" "$processing_directory"   
                mkdir "$processing_directory"/analysis "$processing_directory"/logs

                echo "Submitting subsampling job for job $j"
                subsampling_job=$(sbatch --parsable "$path_to_subsampling_script" "$fastq_directory" "$percentage")
                echo "subsampling_job: $subsampling_job"
                echo "Submitting pipeline job for job $j"

                ### Set the dependency on the completion of all matching jobs for run_pipeline_job ###
                run_pipeline_job=$(sbatch --parsable --dependency=afterok:$subsampling_job "$path_to_pipeline_script" "$fastq_directory" "$processing_directory" "$percentage")
                echo "run_pipeline_job: $run_pipeline_job"
                batch_jobs+=("$run_pipeline_job")  
                echo "batch_jobs: ${batch_jobs[@]}"
            fi
        done

        # Wait for the current batch to complete
        while [[ "${batch_job_statuses[@]}" =~ "0" ]]; do
            batch_job_statuses=()
            for job_id in "${batch_jobs[@]}"; do
                if [[ $(squeue -h -j $job_id -t PD,R) ]]; then  # Check if jobs are completed
                    batch_job_statuses+=(0)  # If any job is not completed, set completed to no
                fi
            done

            if [[ "${batch_job_statuses[@]}" =~ "0" ]]; then
                sleep 25
            fi
        done
    done
    # Proceed to the next batch
done
