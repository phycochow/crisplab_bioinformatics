#!/bin/bash
#SBATCH --job-name=parameter_sweep
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=2:00:00
#SBATCH --partition=general
#SBATCH --requeue

usage="USAGE:
bash parameter_sweep.sh <list_of_percentages>"

######### Setup ################
path_to_pipeline_script=/home/s4669612/gitrepos/crisplab_wgs/pipeline.sh
path_to_outputs=output.csv
# Check if the number of arguments is correct
if [ $# -eq 0 ]; then
  echo "Error: No percentages provided."
  echo "$usage"
  exit 1
fi

# Get the list of percentages from the command-line argument
percentages=$@

# Loop over each percentage and process the files, the random seed -s100 is to ensure the subsampling works on the paired reads, it should work with any number
for percentage in "${percentages[@]}"; do
# Copy the raw_reads into the temporary read folder to be processed
  for file in ../../raw_reads/*; do
    cp "$file" ../inputs/reads
  done
  
# Subsamples and uncompress the fastqz files
for file in ../inputs/reads/*; do
  /home/s4669612/software/seqtk/seqtk sample -s100 "$file" "$percentage" > "${file%.fastq.gz}.fastq"
done
      
# Delete all compressed files in the new directory
for file in ../inputs/reads/*.fastq.gz; do
    rm "$file"
done
  
# Run and wait for the pipeline job to complete
run_pipeline_job=$(sbatch --parsable "$path_to_pipeline_script")
if [ -n "$run_pipeline_job" ]; then
  echo "Pipeline job submitted with job ID: $run_pipeline_job"
  echo "Waiting for the pipeline job to complete..."
  while true; do
    job_status=$(squeue -j "$run_pipeline_job" -h -t PD,R)
    if [ -z "$job_status" ]; then
      echo "Pipeline job completed."
      break
    fi
    sleep 30
  done
else
  echo "Error: Failed to submit the pipeline job."
  exit 1
fi

source /home/s4669612/miniconda3/bin/activate py3.7
# Store the ouputs: Loop over each vector in the vector library - to be improved (ask pete about coverage, read counts and other features logs)
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")
for vector in "${vector_list[@]}"; do
  for file in analysis/trimmed_align_bowtie2/*.bam; do
    python /home/s4669612/gitrepos/crisplab_wgs/update_excel.py "$vector" "$file" ../outputs/output.csv ;
  done
done
conda deactivate
done


