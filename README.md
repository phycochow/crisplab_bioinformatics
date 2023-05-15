# Peter-Crisp's-lab-NGS-transgene-detection-project
These scripts develop a reliable model to determine transgenic organisms by extracting features from NGS data for supervised learning.

This is one of my undergrad projects under Dr Peter Crisp at the University of Queensland.
 
To install, go to terminal and:
```bash
git clone https://github.com/phycochow/crisplab_wgs.git
```

The working directory is defined as the parent of 3: outputs, inputs, processing; and the sibling of raw_reads_template 

To run the parameter_sweep:
```bash
cd path/to/directory/with/4/files
parameter_sweep.sh path/to/directory/with/fastq/or/fastq.gz/NGS/read/files
```
https://www.makeareadme.com/
