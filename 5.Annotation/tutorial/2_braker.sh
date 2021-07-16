#!/bin/sh
###############################################################
# pipeline for running braker on bam files   #
#                                                             #
# usage:                                                      #
#                                                             #
#      2_braker.sh $base_dir $CPU                             #
#                                                             #
###############################################################

cd $1

#Installing biopython in case biopython is not available
pip3 install biopython

#moving gm_key to accessible directory
cd 
cp /opt/gmes_linux_64/gm_key_64.gz .
gunzip gm_key_64.gz 
mv gm_key_64 .gm_key

#copying Augustus config file to create species parameters
mkdir $HOME/augustus
cp -r /opt/Augustus/config $HOME/augustus

#paths to export for software
export PATH=/opt/BRAKER-2.1.6:/opt/BRAKER-2.1.6/scripts:$PATH
export AUGUSTUS_CONFIG_PATH=$HOME/augustus/config
export AUGUSTUS_BIN_PATH=/opt/Augustus/bin
export AUGUSTUS_SCRIPTS_PATH=/opt/Augustus/scripts
export TMPDIR=$HOME/tmp
export GENEMARK_PATH=/opt/gmes_linux_64
export HTSLIB_INSTALL_DIR=/opt/htslib-1.13/

#mv to annotation working dir
cd /scratch/annotation_output
mkdir braker_out

braker.pl --genome=contig_15_masked.fasta --bam=SRR5046448_contig15.sort.bam \
--softmasking --workingdir=./braker_out --cores 2 --gm_max_intergenic 100000 &> test1