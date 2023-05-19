import pysam
import argparse
import pandas as pd


def count_mapped_reads():
    # parse the command-line arguments
    parser = argparse.ArgumentParser(description="Count mapped reads in a BAM file in a specific region.")
    parser.add_argument("vector_id", type=str, help="Chromosome name (e.g. chr1)")
    # parser.add_argument("start_pos", type=int, help="Start position of the region of interest")
    # parser.add_argument("end_pos", type=int, help="End position of the region of interest")
    parser.add_argument("bam_file", type=str, help="Name of the BAM file to analyze")
    parser.add_argument("sample_name", type=str, help="Name of sample")
    parser.add_argument("output_file", type=str, help="Name of the output Excel file")
    
#     
    parser.add_argument("read_count", type=float, help="Read Count")
    parser.add_argument("percent_reads_adapter_r1", type=float, help="Percent reads with adapter R1")
    parser.add_argument("percent_reads_adapter_r2", type=float, help="Percent reads with adapter R2")
    parser.add_argument("percent_bp_trimmed_r1", type=float, help="Percent basepairs trimmed R1")
    parser.add_argument("percent_bp_trimmed_r2", type=float, help="Percent basepairs trimmed R2")
    parser.add_argument("raligned_1_time", type=float, help="Average alignment time (s)")
    parser.add_argument("multi_mappings", type=float, help="Percent reads mapped to multiple locations")
    parser.add_argument("unmapped", type=float, help="Percent unmapped reads")
    parser.add_argument("total_alignments", type=float, help="Total number of alignments")
    parser.add_argument("mapq10", type=float, help="Percent reads with mapping quality >= 10")
    parser.add_argument("mapq10_percent", type=float, help="Percent of mapped reads")
    parser.add_argument("percentage", type=float, help="Percent of mapped reads")
    

#    
    args = parser.parse_args()

    # open the BAM file
    bamfile = pysam.AlignmentFile(args.bam_file, "rb")

    # iterate over the reads in the region of interest
    mapped_reads, start_index, end_index = 0, 0, bamfile.get_reference_length(args.vector_id)
    for read in bamfile.fetch(args.vector_id, start_index, end_index):
        if not read.is_unmapped:
            mapped_reads += 1
    
    # Calculate read coverage by getting the reference sequence length for the specified chromosome by id
    total_bases = bamfile.get_reference_length(args.vector_id)
    covered_bases = 0
    for pileupcolumn in bamfile.pileup(args.vector_id):
        if pileupcolumn.n > 0:
            covered_bases += 1

    # Calculate the coverage percentage
    coverage_percentage = float((covered_bases / total_bases) * 100)

    df = pd.read_csv(args.output_file)

    # add row 
    new_row = [args.sample_name, 
               args.percentage,
               args.vector_id, 
               start_index, 
               end_index, 
               mapped_reads, 
               coverage_percentage, 
               args.read_count, 
               args.percent_reads_adapter_r1,
               args.percent_reads_adapter_r2, 
               args.percent_bp_trimmed_r1,
               args.percent_bp_trimmed_r2,
               args.raligned_1_time,
               args.multi_mappings,
               args.unmapped, 
               args.total_alignments, 
               args.mapq10, 
               args.mapq10_percent
               ]
    df.loc[len(df)] = new_row

    # write the output to an csv file
    df.to_csv(args.output_file, index=False)


if __name__ == "__main__":
    """This runs the python file as a script and prevents the terminal from treating it as a module."""
    count_mapped_reads()  # Updates a preexisting csv file

    
