# Peter-Crisp's-lab-NGS-transgene-detection-project
This script extract features from NGS data through subsampling and mapping it to bacterial vectors. The features combined with the known ground truth of the transgenic samples enable supervised learning. This is a project only made possible by Dr Peter Crisp at the University of Queensland.
 
To install, go to terminal and:
```bash
git clone https://github.com/phycochow/crisplab_wgs.git
```

The following script needs to be run in directory with 4 files: outputs, inputs, processing, raw_reads_template
To run the script:
```bash
cd path/to/directory/with/4/files
parameter_sweep.sh path/to/directory/with/fastq/or/fastq.gz/NGS/read/files
```
https://www.makeareadme.com/
