#!/bin/bash

#SBATCH --job-name=My_NGS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=100:00:00
#SBATCH --partition=general
#SBATCH --account=a_crisp

#################################### Setup ########################################
usage="USAGE:
bash 00-main.sh <working_directory>"

working_directory=$1

# Path to the main script
path_to_parameter_sweep_script=/home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh
path_to_subsampling_script=/home/s4669612/gitrepos/crisplab_wgs/00-subsample_fastqgz.sh

# Construct the list of percentages - constant throughout the script
percentages=(0.95 0.07 0.93 0.09 0.91 0.11 0.89 0.13 0.87 0.15 0.85 0.17 0.83 0.19 0.81 0.21 0.79 0.23 0.77 0.25 0.75 0.27 0.73 0.29 0.71 0.30 0.70 0.31 0.69 0.33 0.67 0.35 0.65 0.37 0.63 0.39 0.61 0.41 0.59 0.42 0.58 0.43 0.57 0.45 0.55 0.47 0.53 0.49 0.51 0.50)

no_percentages=${#percentages[@]}

#################################### Run ########################################
# Specify the number of duplicates and the batch size
total_jobs=50
batch_size=4
max_value=0
total_time=0
running_pipelines=()

for ((run_id=1; run_id<=total_jobs; run_id++)); do

    echo "Processing batch: $run_id to $((run_id+batch_size-1)), running_pipelines has been reset"

    if [[ ${#running_pipelines[@]} -lt $batch_size ]]; then
        # Set index and percentage
        index=$((run_id % no_percentages))
        percentage=${percentages[$((index-1))]}
        echo "Processing run: $run_id, Processing percentage: $percentage"

        # Go/return to parent directory of inputs outputs and processing
        cd "$working_directory"

        # Store and create directories with id number & respective percentage
        fastq_directory="$working_directory"/inputs/reads"$run_id"_"$percentage"
        processing_directory="$working_directory"/processing"$run_id"_"$percentage"
        mkdir "$fastq_directory" "$processing_directory"
        mkdir "$processing_directory"/analysis "$processing_directory"/logs

        echo "Submitting subsampling job: $subsampling_job and run_pipeline_job: $run_pipeline_job for run $run_id"
        subsampling_job=$(sbatch --parsable "$path_to_subsampling_script" "$fastq_directory" "$percentage")
        run_pipeline_job=$(sbatch --parsable --dependency=afterok:$subsampling_job "$path_to_pipeline_script" "$fastq_directory" "$processing_directory" "$percentage")

        # Add the running pipeline job to the wait list
        running_pipelines+=("$run_pipeline_job")
        echo "running_pipelines: ${running_pipelines[@]}"
    fi
    
    # If the number of running pipelines is equal to batch size, check status, and remove from running pipeline list if done
    while [[ ${#running_pipelines[@]} -eq $batch_size ]]; do
        
        # Update storage and sleep 4 minutes
        value=$(/usr/lpp/mmfs/bin/mmlsquota -j S0100 --block-size=auto scratch | awk 'NR==3 {sub(/.$/,"",$3); print $3}')
        if (( $(echo "$value > $max_value" | bc -l) )); then
            max_value=$value
        fi
        echo "Data storage peaked at: $max_value GB, total run time for up to job: $run_id for $total_time minutes, sleeping for 4 minutes"
        ((total_time+=4))
        sleep 240
        
        
        echo Checking status of jobs...
        updated_running_pipelines=()
        
        # Checks status of each job and add to updated_running_pipelines
        for job_id in "${running_pipelines[@]}"; do
            squeue_rows=$(squeue -h -j "$job_id" -t PD,R 2>/dev/null | wc -l)

            # if the number of rows (excepts invalid id) for a specific running/pending pipeline > 0, then the job is not completed
            if [[ $squeue_rows -gt 0 ]]; then
                updated_running_pipelines+=("$job_id")
            else
                echo "Pipeline $job_id is completed"
            fi
        done

        running_pipelines=("${updated_running_pipelines[@]}")
    done
done
