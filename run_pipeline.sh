#!/bin/bash
#SBATCH --job-name=my_pipeline
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --array=1-4%1
#SBATCH --partition=general
#SBATCH --requeue

# Submit the first job and get the job ID
fastqc_job=$(sbatch --parsable /home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-qc_sbatch.sh ../samples.txt 2:00:00 8 a_crisp)

# Run MultiQC after FastQC is done
if [[ $SLURM_ARRAY_TASK_ID == 2 ]]; then
  cd analysis/fastqc_raw
  conda activate py3.7
  multiqc .
  cd ../..
fi

# Submit the second job and set its dependency on the first job
trim_galore_job=$(sbatch --parsable --dependency=afterok:$fastqc_job /home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-trim_galore_gz_sbatch.sh ../samples.txt 20:00:00 16 a_crisp)

# Submit the third job and set its dependency on the second job
bowtie2_job=$(sbatch --parsable --dependency=afterok:$trim_galore_job /home/s4669612/gitrepos/crisplab_epigenomics/WGS/02-bowtie2_sbatch.sh ../samples.txt trimmed 6 /scratch/project/crisp008/chris/NGS_project/sorghum/Sbicolor_454_v3.0.1_vectors 10 18:00:00 40 a_crisp)

# Submit the fourth job and set its dependency on the third job
deeptools_job=$(sbatch --parsable --dependency=afterok:$bowtie2_job /home/s4669612/gitrepos/crisplab_epigenomics/WGS/03b-deeptools_bigWig_sbatch.sh ../samples.txt 2:00:00 45 /scratch/project/crisp008/chris/NGS_project/test3/analysis/trimmed_align_bowtie2 py3.7 a_crisp)


