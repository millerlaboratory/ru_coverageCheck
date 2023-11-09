# Coverage and Sex Check for a single target

Use this shell script to quickly compute depth of coverage within one gene region and two controls.

This utility assumes that you have sequenced FMR and COL1A1 in the case of adaptive sampling. 

## Requirements

- samtools >= 1.15
- rust >= 1.72.1

## Usage

Supply haplotagStats.sh with a region (`-r`) in the format `chrN:12345-23456` and a bam file with flag `-i`.
`haplotagStats.sh` expects `haplotagParse` to exist in the same directory.
Output is printed to `stdout` with a header.
Within the region you supply and FMR (X control) and COL1A1 (Somatic control), the following are printed:

**Filename | Region Name | Region Coordinates | Total Average Depth | HP1 Depth | HP2 Depth | Percent Haplotagged**

Pileups are created at 1kb intervals within each region.

Expected run time is ~25 seconds per bamfile

### More suggested usage

Loop over an array of bamfiles and output to a summary file like so:

```{bash}
BAMFILES=( $(ls INPUT_DIRECTORY/*/*.phased.bam) )
REGION="chrX:12343-23456"

./haplotagStats.sh -r $REGION -i ${BAMFILES[0]} > summary.txt

for BAM in ${BAMFILES[@]:1}
do
    ./haplotagStats.sh -r $REGION -i $BAM >> summary.txt
done
```