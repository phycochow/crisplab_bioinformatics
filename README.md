# Peter-Crisp's-lab-NGS-transgene-detection-project
These scripts run the bioinformtaic pipeline to map pair-end reads to a reference genome iteratively to extract features from the process. These features could be used for developing a reliable model with supervised learning to classify transgenic organisms from NGS data. The main script handles the iterative process and the SLURM schedule on Bunya, a high-performance computing cluster.

This is an undergrad project with Dr Peter Crisp at the University of Queensland.
 
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

When you mess up and want to restart:
```bash
cd path/to/working/directory/
for file in slurm*; do rm -r "$file"; done
for file in pro*; do rm -r "$file"; done
for file in inputs/read*; do rm -r "$file"; done
```

https://www.makeareadme.com/
