### Initial Settings ###

# https://github.com/pedrocrisp/crisplab_epigenomics
# https://docs.google.com/document/d/138wm070Uk0C1LoAxPJkPmN5Otq5cCekQ_vJ5wnHtJFA/edit?usp=sharing
# https://link.springer.com/article/10.1007/s00425-017-2722-8

# Bash tutorial
# https://swcarpentry.github.io/shell-novice/

### Work through with Vanessa & SLURM commands ###
cd gitrepos
git clone link

# Go into vim text editor
vim .file_name.txt
# Press i to get into insert mode
# shift+insert
# esc -> :x when done

# Check bim file contents
less .name

# Activate conda
conda activate py3.7
conda deactivate

# ------------------------------------------------------------------
# install miniconda3
cd ~/software

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash Miniconda3-latest-Linux-x86_64.sh
# ------------------------------------------------------------------

# install Multiqc
# ------------------------------------------------------------------
# create virtual environments to manage python software (^) - one off
conda create --name py3.7 python=3.7
conda activate py3.7
conda install -c bioconda -c conda-forge multiqc
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Add shortcuts
vim .bashrc

# To rename files
mv old_name new_name

# ------------------------------------------------------------------
# set up project directory
cd /scratch/project/crisp008/chris/Chris_WGS_sorg
mkdir analysis logs

# ------------------------------------------------------------------
# create sample listing
# ------------------------------------------------------------------

cd /scratch/project/crisp008/chris/Chris_WGS_sorg/reads
find *R1.fastq.gz | sed 's/R1\.fastq\.gz//' > ../samples.txt

# ------------------------------------------------------------------
# run fastqc
# ------------------------------------------------------------------

cd /scratch/project/crisp008/chris/Chris_WGS_sorg

bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-qc_sbatch.sh \
samples.txt \
2:00:00 \
8 \
a_crisp

/scratch/project/crisp008/chris/samples.txt

# add shortcut to project space
# ------------------------
cd ~/
vim .bash_aliases
# i for insert mode
# move to end of "alias list"
# to add to bottom of "alias list" shift + insert to paste below
alias cds='cd /scratch/project/crisp008/chris/Chris_WGS_sorg'
# esc to leave insert mode
# :x to exit vim
# exit Bunya, log back in and check cds shortcut worked
cdn # (open latest file)
cds # Project directory
lah # similar to ls -a
# ------------------------
# confirm that fastqc ran successfully
# ------------------------
# go to your project space
# navigate to your logs directory
# change into analysis directory and check fastqc_raw contents
# should be *fastqc.zip and * fastqc.html files

# change into the fastqc directory with a suffix "-qc"
# check error files for exit status using less command (they start with 01-qc_e_*)
less 01-qc_e_3243604_1
# exit status is at the end of the file, shift+g to skip to the file end
# if ran successfully ExitStatus = 0
# q to exit

# convert the suffixes from *.fq.gzto *fastq.gz
cd /scratch/project/crisp008/chris/Chris_WGS_sorg/analysis/reads
for file in *.fq.gz; do mv "$file" "${file%.fq.gz}.fastq.gz"; done


# Run from project directory qc
bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-qc_sbatch.sh \
samples.txt \
2:00:00 \
8 \
a_crisp

# Run multiqc
cd analysis/fastqc_raw

# if virtual environment is not running then run this:
conda activate py3.7

multiqc .
# Next steps:
#trim
cd /scratch/project/crisp008/chris/sorg_transgene_check/ykaf9

#01-trim_galore
bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-trim_galore_gz_sbatch.sh \
samples.txt \
20:00:00 \
16 \
a_crisp

# Rename the files again
for file in *READ_1.fastq.gz; do mv "$file" "${file%READ_1.fastq.gz}R1.fastq.gz"; done
for file in *READ_2.fastq.gz; do mv "$file" "${file%READ_2.fastq.gz}R2.fastq.gz"; done

# Check ran jobs
squeue - u < your_user_name >
# Check jobs in queue
scontrol show job <your_job_number>
# Check all ran jobs
sacct -u <your_user_name>
# Update interactive job time
scontrol update jobid=<job_id> TimeLimit=<new_timelimit>


scancel #jobId
# ------------------------------------------------------------------
# Install trimgalore to software
cd ~/software
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.5.tar.gz -o trim_galore.tar.gz
tar xvzf trim_galore.tar.gz
# add to path
#check executables:
find /home/s4669612/software/TrimGalore-0.6.5/ -type f -executable -exec echo {} \;
#link to bin
find /home/s4669612/software/TrimGalore-0.6.5/ -type f -executable -exec ln -s {} ~/bin/ \;
#  Access RDM
cd /QRISdata/Q5873/Chris_WGS_sorg
# ------------------------------------------------------------------

# copy fastqc output to undergrad RDM
cd /scratch/project/crisp008/chris/Chris_WGS_sorg/analysis
rsync -rhivPt fastqc_raw /QRISdata/Q5873/Chris_WGS_sorg/analysis/

rsync -rhivPt Chris_WGS_sorg_subsample_1/ /QRISdata/Q5873/Chris_WGS_sorg/Chris_WGS_sorg_subsample_1/

# ------------------------------------------------------------------
# Run Bowtie
cd /scratch/project/crisp008/chris/Chris_WGS_sorg

bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/02-bowtie2_sbatch.sh \
../samples.txt \
trimmed \
6 \
/scratch/project/crisp008/chris/Chris_WGS_sorg/sorghum/Sbicolor_454_v3.0.1_vectors \
10 \
18:00:00 \
40  \
a_crisp

# Reference options
Sbicolor_454_v3.0.1_vectors
zCas9_vectors
# ------------------------------------------------------------------
# Genmap
# ------------------------------------------------------------------
$ ./genmap index -F /path/to/fasta.fasta -I /path/to/index/folder
# A new folder /path/to/index/folder will be created to store the index and all associated files.
export TMPDIR=/somewhere/else/with/more/space
# To compute the (30,2)-mappability of the previously indexed genome, simply run:
$ ./genmap map -K 30 -E 2 -I /path/to/index/folder -O /path/to/output/folder -t -w -bg
# This will create a text, wig and bedGraph file in /path/to/output/folder storing the computed mappability
# in different formats. You can omit formats that are not required by removing the corresponding flags -t -w or -bg.
#
# Instead of the mappability, the frequency can be outputted, you only have to add the flag -fl to the previous command.


# ------------------------------------------------------------------
# reduce the number of reads subsampling
# ------------------------------------------------------------------
samtools view -s 0.05 -@ 2 align_bowtie2_k100_no_mismatch_MAPQ5/Hv-input_sorted.bam -o align_bowtie2_k100_no_mismatch_MAPQ5_subsample/Hv-input_sorted.ban

# Removed the statistical outputs to WGS_Sorg logs



# Creating statistical summaries
# generate total reads summary from trimmed logs
cd logs
cd <trimminglog folder>

#create header for file:
echo -e "Sample\tTotal_sequences_analysed\tPERCENT_READS_WITH_ADAPTERS_R1\tPERCENT_READS_WITH_ADAPTERS_R2\tPERCENT_BP_TRIMMED_R1\tPERCENT_BP_TRIMMED_R2" > ../total_reads_summary.tsv

#scrape logs:
for i in $(ls 01-trim_galore_gz_e*); do
SAMPLE=$(grep '+ ID=' $i | cut -d "=" -f 2)
TOTAL_READS=$(grep 'Total number of sequences analysed:' $i | tr -s ' ' | cut -d " " -f 6)
PERCENT_READS_WITH_ADAPTERS=$(grep 'Reads with adapters:' $i | tr -s ' ' | cut -d " " -f 5 | paste -sd '\t')
PERCENT_BP_TRIMMED=$(grep 'Quality-trimmed:' $i | tr -s ' ' | cut -d " " -f 4 | paste -sd '\t')
echo -e "$SAMPLE\t$TOTAL_READS\t$PERCENT_READS_WITH_ADAPTERS\t$PERCENT_BP_TRIMMED"
done >> ../total_reads_summary.tsv

#view output:
cat ../total_reads_summary.tsv | column -t

# generate bowtie2 summary
# Step 2 - run scraper script on error files for batch 1 (login)

cd logs
cd <bowtie2 log folder>

# Part 1 - creates empty text file

echo -e "sample\tALIGNED_1_TIME\tMULTI_MAPPINGS\tUNMAPPED" > bowtie2_summary.tsv

# Part 2 - fills in table 'bowtie2_summary'

for i in $(ls 02-bowtie2_e*); do
SAMPLE=$(grep 'echo sample being mapped is' $i | cut -d " " -f 7)
ALIGNED_1_TIME=$(grep ') aligned concordantly exactly 1 time' $i | cut -d " " -f 6)
MULTI_MAPPINGS=$(grep ' aligned concordantly >1 times' $i | cut -d " " -f 6)
UNMAPPED=$(grep ') aligned concordantly 0 times' $i | cut -d " " -f 6)
echo -e "$SAMPLE\t$ALIGNED_1_TIME\t$MULTI_MAPPINGS\t$UNMAPPED"
done >> bowtie2_summary.tsv

# Part 3 - prints table to the screen

cat bowtie2_summary.tsv | column -t
# run scraper script on output files (login) - batch 1

cd logs
cd <bowtie2 log folder>

echo -e "sample\tTOTAL_ALIGNMENTS\tMAPQ10\tPERCENT" >MAPQ_filter_summary.tsv
for i in $(ls 02-bowtie2_o*); do
SAMPLE=$(grep 'sample being mapped is' $i | cut -d " " -f 5)
TOTAL_ALIGNMENTS=$(grep -A1 'total alignments before MAPQ filter' $i | grep -v "total alignments before MAPQ filter")
MAPQ10=$(grep -A1 'total alignments after MAPQ filter' $i | grep -v "total alignments after MAPQ filter")
if [[ "$TOTAL_ALIGNMENTS" -ne 0 ]]; then
    PERCENT=$(awk -v mapq10="$MAPQ10" -v total="$TOTAL_ALIGNMENTS" 'BEGIN { printf("%d\n", (mapq10 / total) * 100 + 0.5) }')
else
    PERCENT=0
fi
echo -e "$SAMPLE\t$TOTAL_ALIGNMENTS\t$MAPQ10\t$PERCENT"
done >> MAPQ_filter_summary.tsv
# MAPQ_filter_summary.tsv output (RESULTS) (for maize, approx 60% (percent) - look this up for sorghum)
cat MAPQ_filter_summary.tsv | column -t

# ------------------------------------------------------------------
# run deepTools to convert bams to bigWigs

# to install deeptools
# install deeptools

cd ~/software

conda activate py3.7

conda install -c bioconda deeptools

cd /scratch/project/crisp008/chris/Chris_WGS_sorg
# ------------------------------------------------------------------
bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/03b-deeptools_bigWig_sbatch.sh \
samples.txt \
2:00:00 \
45 \
/scratch/project/crisp008/chris/Chris_WGS_sorg_e/analysis/trimmed_align_bowtie2 \
py3.7 \
a_crisp

Chris_WGS_sorg_subsample_1
Chris_WGS_sorg
# ------------------------------------------------------------------

### Start of documentary ###
# 07042023
# Goal: Where to run samtools to obtain the reduced reads
#  I believe this code only takes bam files as input.  Source: http://www.htslib.org/doc/samtools-view.html
samtools view -s 0.05 -@ 2 align_bowtie2_k100_no_mismatch_MAPQ5/Hv-input_sorted.bam -o align_bowtie2_k100_no_mismatch_MAPQ5_subsample/Hv-input_sorted.ban
# So in order to subsample the fastq files, I think I need something else like Seqtk which only takes one line of code:
seqtk sample -s100 read1.fq 0.2 > sub1.fq
# This gives us 10% of the original file
/home/s4669612/software/seqtk/seqtk sample -s100 Tx430_2020___D3_R1.fastq.gz 0.1 > sub1.fq.gz
# The files were too big, so rename to sub1.fq and run inbuilt gzip (warning! it takes forever to compress):
gzip *.fastq

# 11042023
# Goal: Subsample all files and test run
# Judging from Pete's script to rename:
for file in *.fq.gz; do mv "$file" "${file%.fq.gz}.fastq.gz"; done
#  I think I can:
for file in *; do /home/s4669612/software/seqtk/seqtk sample -s100 "$file" 0.6 | gzip > "new_$file"; done
# then:
for file in new_*; do mv to somewhere
# or
find. -not -namen'new_*' - type f - delete


# 12042023
# Got IGV to work
# Fixed some mistakes I made earlier by rsync files into the wrong directories (I blame it on the directories)
def print_sample_list:
    x = ["Tx430_2020___D3",
    "Tx430_glasshouse_21_embryo_season___A3",
    "Tx430_TC_control___A1",
    "y-kaf9-1___B10",
    "y-kaf9-2___A10",
    "y-kaf9-2___C10",
    "y-kaf9-2___D9",
    "y-kaf9-2___E9",
    "y-kaf9-2___F9",
    "y-kaf9-2___G9",
    "y-kaf9-2___H9",
    "y-kaf9-3___D10"]
# 13042023
# Renamed, and made new directories for vector mapping
for file in *; do mv "$file" "cas9_$file"; done
    cas9

cds
for file in *; do rsync -rhivPt "$file" /QRISdata/Q5873/Chris_WGS_sorg/; done

# Not sure if the zcas9 files in sorghum directory are the only vector files to test <- yes, it is 2-in-1 vector file

# 17042023
# Some conversation with Pete to be saved
# for MapQ info:
# http://biofinysics.blogspot.com/2014/05/how-does-bowtie2-assign-mapq-scores.html
# https://www.biostars.org/p/101533

# 19032023
# A quick presentation for Karen and Pete
for file in new_*;do rm "$file";done

#24032023
# Sample list 2
CPDI2-2___A6
CPDI2-2___B6
CPDI2-2___C6
CPDI2-2___F5
CPDI2-2___G5
CPDI2-2___H5
CPDI2-5___A5
CPDI2-5___B5
CPDI2-5___H4
CPDI3-1-1___D6
CPDI3-1-1___E6
CPDI3-1-1___F6
CPDI3-2-3___C5
CPDI3-2-3___D5
CPDI3-2-3___E5
Tx430_2020___D3
Tx430_glasshouse_21_embryo_season___A3

# Deleted most directories to restart everything
# made new directory called NGS_project with merged raw reads and sample list
# new script to automate everything:
bash \
/home/s4669612/gitrepos/crisplab_epigenomics/WGS/01-qc_sbatch.sh \
samples.txt \
2:00:00 \
8 \
a_crisp

# This guy is a god 26052023 comment: not really. that did not cause the failure of job dependency
https://stackoverflow.com/questions/50318838/slurm-dependencyneversatisfied-error-even-after-crashed-job-re-queued

# I built the automated pipline that runs jobs one by one
https://support.pawsey.org.au/documentation/display/US/Example+Workflows#ExampleWorkflows-Jobarrays

# Bunya guide cuz the link is missing
https://github.com/UQ-RCC/hpc-docs/blob/main/Bunya-User-Guide.md

# 20042023 - 26042023
# Brunt forced my way through bugs by changing the gitrepos scripts. Particularly copying code from trim_galore.sbatch
# about some directory thingy to the bowtie file. The errors made my automate.sh unable to run, now it's fixed. Compare
# the scripts for more info, it's just a few line thing.

script_dir=~/gitrepos/crisplab_epigenomics/WGS
script_to_sbatch=${script_dir}/${step}.sh
cat $script_to_sbatch > ${log_folder}/script.log
cat $0 > ${log_folder}/sbatch_runner.log

# Commented these in the bigwig scrip
#make analysis dir if it doesnt exist yet
# analysis_dir=analysis
# mkdir -p $analysis_dir


# Made a python script to process whether there are mapped reads. I am tired and sick of staring into Bunya's souless
# black screen. So me make my own output file so me process it with my own laptop in the beloved python console.
# It takes five arguments in the following order: chromosome, start_pos, end_pos, bam_file, and output_file

conda activate py3.7
my_script.py chr1 1000 2000 my_bam_file.bam output.csv

# Unfortunately, it is not perfectly designed at the moment. I need to know the output of GenMap before perfecting it.
# Treat this as a proof of concept

# Installed FileZilla according to Bunya's guide to upload python files

# Changed run_pipeline.sh to change directory after bowtie2, made test3 directory to test

# 27042023
# I updated the python script to apply the algorithm to the whole chromosome instead of a selected region
# for convenience
/scratch/project/crisp008/chris/NGS_project/test3/analysis
/home/s4669612/gitrepos/crisplab_epigenomics/WGS
# fixed another another in script related to relative path and made test4, moved bam to home directory to debug pyscript

# 03052023
# Amazing website here
# https://www.kofler.or.at/bioinformatic/unix-one-liner/

# 05052023
# Cleared all file in NGS_project directory, made github and will make changes there directly to keep track of everything

# 06052023
# nohup bash parameter_sweep.sh 0.2 0.3

# 07052023
# To leave while code runs
tmux new-session -s mysession
# Crtl B then d to leave
tmux attach-session -t mysession

/scratch/project/crisp008/chris/analysis/trimmed_align_bowtie2/

# Testing python script
cd
cd gitrepos/crisplab_wgs/
# When no permission in github scripts
rm feature_extraction.py
git pull
git checkout -- 04-feature_extraction.py
chmod +x 04-feature_extraction.py
cd /scratch/project/crisp008/chris/analysis/trimmed_align_bowtie2/
conda activate py3.7
python /home/s4669612/gitrepos/crisplab_wgs/feature_extraction.py Cloned_ykaf_nptII y-kaf9-2___C10_sorted.bam output.csv
python /home/s4669612/gitrepos/crisplab_wgs/feature_extraction.py P2_P_Contig_1__zCas9 y-kaf9-2___C10_sorted.bam output.csv


bash /home/s4669612/gitrepos/crisplab_wgs/parameter_sweep.sh 1


# 08052023
# to index files for IGV
samtools faidx <ref_genome.fa>


source /home/s4669612/miniconda3/bin/activate py3.7
# Store the ouputs: Loop over each vector in the vector library - to be improved (ask pete about coverage, read counts and other features logs)
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")
for vector in "${vector_list[@]}"; do
  for file in analysis/trimmed_align_bowtie2/*.bam; do
    python /home/s4669612/gitrepos/crisplab_wgs/04-feature_extraction.py "$vector" "$file" ../outputs/output.csv ;
  done
done
conda deactivate
done


conda install -c bioconda genmap

# 13052023
# GenMap and obtain avg std of read length to calculate mappability
#!/bin/bash

# Output file name
output_file="read_stats.txt"

# Loop over each fastq file in the current directory
for file in *.fastq; do
  echo "Processing file: $file"

  # Calculate the average length and standard deviation of reads
  avg_length=$(awk '{sum += length($0)} END {printf "%.2f", sum/NR}' "$file")
  std_dev=$(awk -v avg="$avg_length" '{sum += (length($0) - avg)^2} END {printf "%.2f", sqrt(sum/NR)}' "$file")

  # Print the results to the output file
  echo "File: $file" >> "$output_file"
  echo "Average Length: $avg_length" >> "$output_file"
  echo "Standard Deviation: $std_dev" >> "$output_file"
  echo "---------------------------" >> "$output_file"

  echo "Completed processing file: $file"
done

echo "Read statistics saved in $output_file"
# I set up github today, learning how to use it


# 14052023
# Check available space
du -h --max-depth 1 | sort -hr
/usr/lpp/mmfs/bin/mmlsquota -j S0100 --block-size=auto scratch

source /home/s4669612/miniconda3/bin/activate py3.7
vector_list=("P2_P_Contig_1__zCas9" "Cloned_ykaf_nptII")
for vector in "${vector_list[@]}"; do
  for file in *.bam; do
    python /home/s4669612/gitrepos/crisplab_wgs/04-feature_extraction.py "$vector" "$file" output.csv ;
  done
done
conda deactivate
done


#  15052023
# Renamed the scripts, I like how pete named them numerically so they are sorted and easy to see
/usr/lpp/mmfs/bin/mmlsquota -j S0100 --block-size=auto scratch
du -h --max-depth 1 | sort -hr

# 2_parameter_sweep
bash /home/s4669612/gitrepos/crisplab_wgs/00-parameter_sweep.sh 0.01 0.1 0.6 919

# 1_pipeline
for file in ../raw_reads_template/*; do cp "$file" inputs/reads; done

for file in *; do
/home/s4669612/software/seqtk/seqtk sample - s100 "$file" 0.99 > "${file%.fastq.gz}.fastq"
rm "$file"
done


bash /home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh "$working_directory"/inputs/reads/ "$working_directory"/processing/

# To leave while code runs
tmux new-session -s mysession
# Crtl B then d to leave
tmux attach-session -t mysession

git pull

squeue -u s4669612
scancel

# 16052023
# copied everything useful in parameter sweep to main and subsample
for file in slurm*; do rm "$file"; done

sbatch /home/s4669612/gitrepos/crisplab_wgs/00-pipeline.sh "$working_directory"/inputs/reads "$working_directory"/processing 0.2
sbatch /home/s4669612/gitrepos/crisplab_wgs/00-subsample_fastqgz.sh "$working_directory"/inputs/reads 0.2
sbatch /home/s4669612/gitrepos/crisplab_wgs/00-main.sh "$p"


git checkout -- 04-feature_extraction.py
chmod +x 04-feature_extraction.py

# jobarray
# https://ri.itservices.manchester.ac.uk/csf4/batch/job-arrays/
percentage"

# 19/05/2023
# All done
sbatch /home/s4669612/gitrepos/crisplab_wgs/00-main.sh $(pwd) 0.09 0.99

for file in slurm*; do rm -r "$file"; done
for file in pro*; do rm -r "$file"; done
for file in inputs/read*; do rm -r "$file"; done
tmux attach-session -t mysession

/usr/lpp/mmfs/bin/mmlsquota -j S0100 --block-size=auto scratch
du -h --max-depth 1 | sort -hr

wc -l < output.csv

# 23/05/2023
# To plot stuff
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
# List of samples for color assignment
green_samples = [
    'y-kaf9-1___B10',
    'y-kaf9-2___C10',
    'y-kaf9-3___D10',
    'Tx430_TC_control___A1',
    'CPDI3-1-1___D6',
    'CPDI3-1-1___E6',
    'CPDI3-1-1___F6',
    'CPDI2-2___B6',
    'CPDI2-2___C6',
    'CPDI2-2___F5',
    'CPDI2-2___G5'
]
for vector in x['Vector'].unique():
    df = x.loc[x['Vector'] == vector]

    # Get unique samples for the vector
    unique_samples = df['Sample'].unique()

    # Generate random colors for samples that are not in the green_samples list
    num_samples = len(unique_samples)
    non_green_samples = list(set(unique_samples) - set(green_samples))
    num_non_green_samples = len(non_green_samples)
    colors = ['green' if sample in green_samples else np.random.rand(3,) for sample in unique_samples]

    # Loop over unique samples
    for sample, color in zip(unique_samples, colors):
        # Filter data for the current sample
        sample_data = df[df['Sample'] == sample]

        # Plot Percentage vs Reads MapQ10 as scatter plot with the specified color
        plt.scatter(sample_data['Subsampled Reads'], sample_data['Coverage'], label=sample, color=color)

    # Set plot labels and title
    plt.xlabel('No. Reads')
    plt.ylabel('Coverage %')
    plt.title(f'{vector}')

    # Display legend
    plt.legend()

    # Show the plot
    plt.show()

# DM -> check NGS_mining.py





