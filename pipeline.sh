#!/bin/bash
#SBATCH --job-name=my_pipeline
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=24:00:00
#SBATCH --array=1-3%1
#SBATCH --partition=general
#SBATCH --requeue

# Set variables 
path_to_sample_list=/scratch/project/crisp008/chris/NGS_project/inputs/samples.txt
path_to_qc_script=/home/s4669612/gitrepos/crisplab_wgs/01-qc_sbatch.sh
path_to_trim_script=/home/s4669612/gitrepos/crisplab_wgs/01-trim_galore_gz_sbatch.sh
path_to_bowtie_script=/home/s4669612/gitrepos/crisplab_wgs/02-bowtie2_sbatch.sh
path_to_reference=/scratch/project/crisp008/chris/NGS_project/inputs/sorghum/Sbicolor_454_v3.0.1_vectors

# Submit the first job and get the job ID
fastqc_job=$(sbatch --parsable "$path_to_qc_script" "$path_to_sample_list" 2:00:00 8 a_crisp)

# Run MultiQC after FastQC is done
if [[ $SLURM_ARRAY_TASK_ID == 2 ]]; then
  cd analysis/fastqc_raw
  conda activate py3.7
  multiqc .
  cd ../..
fi

# Submit the second job and set its dependency on the first job
trim_galore_job=$(sbatch --parsable --dependency=afterok:$fastqc_job "$path_to_trim_script" "$path_to_sample_list" 20:00:00 16 a_crisp)

# Submit the third job and set its dependency on the second job
bowtie2_job=$(sbatch --parsable --dependency=afterok:$trim_galore_job "$path_to_bowtie_script" "$path_to_sample_list" trimmed 6 "$path_to_reference" 10 18:00:00 40 a_crisp)

