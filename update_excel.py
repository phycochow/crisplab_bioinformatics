import pysam
import argparse
import pandas as pd


def oooweeeeeeeeeeee():
    # parse the command-line arguments
    parser = argparse.ArgumentParser(description="Count mapped reads in a BAM file in a specific region.")
    parser.add_argument("chromosome", type=str, help="Chromosome name (e.g. chr1)")
    # parser.add_argument("start_pos", type=int, help="Start position of the region of interest")
    # parser.add_argument("end_pos", type=int, help="End position of the region of interest")
    parser.add_argument("bam_file", type=str, help="Name of the BAM file to analyze")
    parser.add_argument("output_file", type=str, help="Name of the output Excel file")
    args = parser.parse_args()

    # open the BAM file
    bamfile = pysam.AlignmentFile(args.bam_file, "rb")

    # iterate over the reads in the region of interest
    mapped_reads, start_index, end_index = 0, 0, bamfile.get_reference_length(args.chromosome)
    for read in bamfile.fetch(args.chromosome, start_index, end_index):
        if not read.is_unmapped:
            mapped_reads += 1

    df = pd.readDataFrame(arg.output_file)

    # add row [chromosome, start, end, mapped reads]
    df.loc[len(df)] = [args.chromosome, args.start_pos, args.end_pos, mapped_reads]

    # write the output to an Excel file
    df.to_excel(args.output_file, index=False)


if __name__ == "__main__":
    """This runs the python file as a script and prevents the terminal from treating it as a module."""
    oooweeeeeeeeeeee()  # Updates a preexisting csv file
    """terminal input example: my_script.py chr1 my_bam_file.bam output.csv"""
    """my_script.py Cloned_ykaf_nptII my_bam_file.bam output.csv"""
    """Specifically Cloned_ykaf_nptII and P2_P_Contig_1__zCas9"""
    
