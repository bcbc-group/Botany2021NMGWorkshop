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
mkdir $HOME/augustus
mkdir $HOME/augustus/config

#paths to export for software
export PATH=/opt/BRAKER-2.1.6:/opt/BRAKER-2.1.6/scripts:$PATH
export AUGUSTUS_CONFIG_PATH=$HOME/augustus/config
export AUGUSTUS_BIN_PATH=/opt/Augustus/bin
export AUGUSTUS_SCRIPTS_PATH=/opt/Augustus/scripts
export TMPDIR=$HOME/tmp
export GENEMARK_PATH=/opt/gmes_linux_64/
export HTSLIB_INSTALL_DIR=/opt/htslib-1.13/

#mv to annotation working dir
cd /scratch/annotation_output
mkdir braker_out
braker.pl --genome=contig_15.fasta --bam=SRR5046448_contig15.sort.bam \
--softmasking --workingdir=./braker_out --cores 2 --gm_max_intergenic 100000 &> test1
