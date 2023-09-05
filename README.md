# Crisp's Lab NGS Transgene Detection Project
These scripts run the bioinformatic pipeline to map pair-end reads to a reference genome and known transgene vectors. It also extracts features from the iteractive process, which are used to develop of a robust supervised learning model for the classification of transgenic sorghum using Next-Generation Sequencing (NGS) Illumina data. 

This undergraduate project was supervised by Dr. Peter Crisp, Dr. Karen Massel, and the world-renowned Sorghum expert, Professor Ian Godwin at the School of Argicultural and Food Sciences, University of Queensland.

The main script handles the iterative process and the SLURM scheduler.
 
To install, go to terminal and:
```bash
git clone https://github.com/phycochow/crisplab_wgs.git
path_to_scripts=$(pwd)/crisplab_wgs
```

The working directory is defined as the parent of 2: outputs, inputs; and the sibling of raw_reads_template 
  The input directory should contain:
    1) a sorghum directory, which should then contain the reference genome (e.g. Sbicolor_454_v3.0.1.fa);
    2) and a samples.txt file with the sample names e.g.:
         Tx430_2020___D3
         Tx430_glasshouse_21_embryo_season___A3
         Tx430_TC_control___A1
    
The sister directory raw_reads_template should contain fastq files (compressed or uncompressed):
  Tx430_2020___D3.fastq
  Tx430_glasshouse_21_embryo_season___A3.fastq.gz
  Tx430_TC_control___A1.fastq
Make sure the file type is .fastq

To run the code:
```bash
cd path/to/working/directory/
sbatch path_to_scripts/00-main.sh $(pwd)
```
The main script is hard-coded to run odd percentages from 1% to 99%. You could change the list to run it at 99.9%. Running the full samples is not avaiable yet. For that purpose, the scripts in the pipeline also needs to be modified to accept compressed fastq.gz files since the subsampling step converts them to fastq.

When you mess up and want to restart:
```bash
cd path/to/working/directory/
for file in slurm*; do rm -r "$file"; done
for file in pro*; do rm -r "$file"; done
for file in inputs/read*; do rm -r "$file"; done
```

https://www.makeareadme.com/
