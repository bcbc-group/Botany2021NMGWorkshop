#!/bin/bash

#SBATCH --job-name=augustusStringEle
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=END
#SBATCH --mem=35G
#SBATCH --mail-user=bikash.shrestha@uconn.edu
#SBATCH -o optimize_%j.out
#SBATCH -e optimize_%j.err

echo `hostname`

module load gffread/0.12.1 
export AUGUSTUS_CONFIG_PATH=$HOME/Augustus/config/
export AUGUSTUS_BIN_PATH=$HOME/Augustus/bin
export PATH=$HOME/Augustus/bin:$HOME/Augustus/scripts:$PATH

org=/home/FCAM/bshrestha/Augustus/scripts
run=/home/FCAM/bshrestha/Augustus/bin
genome=/labs/Wegrzyn/bikash/easel/arabidopsis/genome

#Generate .gb file from gff (annoation) file
#$org/gff2gbSmallDNA.pl scipio.gff ../contig_15_masked.fasta 1000 genes.raw.gb

#for estimating flanking DNA size
#/usr/share/augustus/scripts/computeFlankingRegion.pl scipio.gff
 
#removing genes that doesn't meet AUGUSTUS gene criteria
#$run/etraining --species=generic --stopCodonExcludedFromCDS=true genes.raw.gb 2> train.err
#cat train.err | perl -pe 's/.*in sequence (\S+): .*/$1/' > badgenes.lst
#$org/filterGenes.pl badgenes.lst genes.raw.gb > genes.gb
#grep -c "LOCUS" genes.*

#randomly split data to training and test sets
#$org/randomSplit.pl genes.gb 200
#grep -c LOCUS genes.gb*

#change permissions on folder so its contents can be edited
#username=`whoami`
#sudo chown $username $HOME/augustus/config/species

#create the new species conf
$org/new_species.pl --species=Ugibba 

#train augustus
#$run/etraining --species=Ugibba genes.gb.train --stopCodonExcludedFromCDS=true

#look at new files created
#ls -ort $AUGUSTUS_CONFIG_PATH/species/Ugibba

#test the training
#$run/augustus --species=Ugibba genes.gb.test | tee firsttest.out
#tail -n 100 ../Botany2020NMGWorkshop/annotation/2transfer/firsttest.out 

#optimize, train and test

###PART III: Final training and testing

#train and test with optimization
$org/optimize_augustus.pl --species=Ugibba genes.gb.train
$run/etraining --species=Ugibba genes.gb.train --stopCodonExcludedFromCDS=true
$run/augustus --species=Ugibba genes.gb.test | tee optimizeTest.out

#generating gff
$run/augustus --species=Ugibba ../contig_15_masked.fasta --gff3=on --outfile=contig15_augustus.gff3
