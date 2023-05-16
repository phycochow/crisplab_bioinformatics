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
# Path to the main script
path_to_parameter_sweep_script=/home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh

# Construct the list of percentages - constant throughout the script
percentages=($(seq 0.01 0.01 0.96))


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
# Specify the total number of jobs and the batch size
total_jobs=400
batch_size=4

# Loop through the job array
for ((i=1; i<=total_jobs; i+=batch_size)); do
    batch_jobs=()

    # Submit jobs for the current batch
    for ((j=i; j<i+batch_size; j++)); do
        if [ $j -le $total_jobs ]; then
            job_id=$(sbatch --dependency=afterok:"$dependency" "$path_to_parameter_sweep_script" "${percentages[@]}" "$i" $j | awk '{print $4}')
            batch_jobs+=("$job_id")
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
    dependency=$(IFS:; echo "${batch_jobs[*]}")
done
