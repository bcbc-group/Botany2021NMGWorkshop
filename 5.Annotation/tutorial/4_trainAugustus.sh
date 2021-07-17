#!/bin/sh
###############################################################
# training AUGUSTUS for species of interest					  #
#                                                             #
# usage: 4_trainAugustus.sh $base_dir $CPU                    #
#                                                             #
#      							                              #
#                                                             #
###############################################################

cd $1
#mkdir $HOME/augustus
#cp -r /opt/Augustus/config $HOME/augustus
mkdir /scratch/annotation_output/augustus_output
cd /scratch/annotation_output/augustus_output

export AUGUSTUS_CONFIG_PATH=$HOME/augustus/config
export AUGUSTUS_BIN_PATH=/opt/Augustus/bin
export AUGUSTUS_SCRIPTS_PATH=/opt/Augustus/scripts
export PATH=/opt/Augustus/bin:/opt/Augustus/scripts:$PATH
export TMPDIR=/scratch/annotation_output/augustus_output
data=/scratch/Botany2020NMGWorkshop/annotation/2transfer

#Training AUGUSTUS requires dataset in GenBank (gb) format
#Generate .gb file from gff (annotation) file
/opt/Augustus/scripts/gff2gbSmallDNA.pl $data/scipio.gff $data/contig_15_masked.fasta 1000 genes.raw.gb

#for estimating flanking DNA size
#/opt/Augustus/scripts/computeFlankingRegion.pl scipio.gff
 
#removing genes that doesn't meet AUGUSTUS gene criteria
/opt/Augustus/bin/etraining --species=generic --stopCodonExcludedFromCDS=true genes.raw.gb 2> train.err

cat train.err | perl -pe 's/.*in sequence (\S+): .*/$1/' > badgenes.lst

/opt/Augustus/scripts/filterGenes.pl badgenes.lst genes.raw.gb > genes.gb

grep -c "LOCUS" genes.* > geneCount.txt

#randomly split data to training and test sets
/opt/Augustus/scripts/randomSplit.pl genes.gb 200

grep -c LOCUS genes.gb* >> geneCount.txt

#create the new species conf
/opt/Augustus/scripts/new_species.pl --species=Ugibba 

#train augustus
/opt/Augustus/bin/etraining --species=Ugibba genes.gb.train --stopCodonExcludedFromCDS=true

#look at new files created
#ls -ort $AUGUSTUS_CONFIG_PATH/species/Ugibba

#test the training
/opt/Augustus/bin/augustus --species=Ugibba genes.gb.test | tee firsttest.out
tail -n 100 /scratch/Botany2020NMGWorkshop/annotation/2transfer/firsttest.out 

#train and test with optimization
/opt/Augustus/scripts/optimize_augustus.pl --species=Ugibba genes.gb.train
/opt/Augustus/bin/etraining --species=Ugibba genes.gb.train --stopCodonExcludedFromCDS=true
/opt/Augustus/bin/augustus --species=Ugibba genes.gb.test | tee optimizeTest.out

#generating gff file
/opt/Augustus/bin/augustus --species=Ugibba $data/contig_15_masked.fasta --gff3=on --outfile=contig15_augustus.gff3
