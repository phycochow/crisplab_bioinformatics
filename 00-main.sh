#!/bin/bash
#SBATCH --job-name=My_NGS
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=200:00:00
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
percentages=($(seq 0.01 0.01 0.03))

# Function to check if all jobs in a batch have completed
check_batch_completion() {
    local completed=1
    for job_id in "${batch_jobs[@]}"; do
        squeue_output=$(squeue -h -j "$job_id" -t "COMPLETED" -o "%j")
        if [ -n "$squeue_output" ]; then
            completed=0
            break
        fi
    done
    return $completed
}

#################################### Run ########################################
# Specify the number of duplicates and the batch size
total_jobs=4
batch_size=2



for percentage in "${percentages[@]}"; do

    # Loop through the job array
    for ((i=1; i<=total_jobs; i+=batch_size)); do
        batch_jobs=()
        
        # Set the dependency for the next batch
        if [ -n "$dependency" ]; then
            dependency_option="--dependency=afterok:$dependency"
        else
            dependency_option=""
        fi
        
        # Submit jobs for the current batch
        for ((j=i; j<i+batch_size; j++)); do
            if [ $j -le $total_jobs ]; then
                # Go/return to parent directory of inputs outputs and processing  
                 cd "$working_directory"
        
                # Store and create directories with id number & respective percentage
                fastq_directory="$working_directory"/inputs/reads"$j"_"$percentage"
                processing_directory="$working_directory"/processing"$j"_"$percentage"
                mkdir "$fastq_directory" "$processing_directory"   
                subsampling_job=$(sbatch --parsable $dependency_option "$path_to_subsampling_script" "$fastq_directory" "$percentage")
                
                mkdir "$processing_directory"/analysis "$processing_directory"/logs
                # Stores job ID with --parsable
                run_pipeline_job=$(sbatch --parsable --dependency=afterok:$subsampling_job "$path_to_pipeline_script" "$fastq_directory" "$processing_directory" "$percentage")
                batch_jobs+=("$run_pipeline_job")  
            fi
        done
        
        # Wait for the current batch to complete
        while true; do
            check_batch_completion
            if [ $? -eq 0 ]; then
                break
            fi
            sleep 10
        done

        # Set the dependency for the next batch
        dependency=$(IFS=:; echo "${batch_jobs[*]}")
    done
done
