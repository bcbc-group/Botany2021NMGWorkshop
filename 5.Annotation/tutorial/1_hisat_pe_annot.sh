#!/bin/sh
###############################################################
# pipeline for running hisat2 on paired end files   #
#                                                             #
# usage:                                                      #
#                                                             #
#      hisat_pe_annot.sh $base_dir $CPU                       #
#                                                             #
###############################################################

cd $1

#make a dir for your output and copy or symlink some files there
mkdir /scratch/annotation_output
cd /scratch/annotation_output
#cp /scratch/Botany2020NMGWorkshop/annotation/2transfer/contig_15.fasta .
ln -s  /scratch/BotanyNMGWorkshop/annotation/2transfer/contig_15_masked.fasta .
ln -s /scratch/BotanyNMGWorkshop/annotation/2transfer/*.fastq .

#index reference fasta file; We will use only contig_15 for demo purposes
 /opt/hisat-genotype-top/hisat2-build contig_15_masked.fasta contig_15

#map RNA-seq reads to reference genome fasta file
for file in `dir -d *_1.fastq` ; do

    samfile=`echo "$file" | sed 's/_1.fastq/.sam/'`
    file2=`echo "$file" | sed 's/_1.fastq/_2.fastq/'`

     /opt/hisat-genotype-top/hisat2 --max-intronlen 100000 --dta -p 7 -x contig_15 -1 $file -2 $file2 -S $samfile

done

samtools view -Sb -o SRR5046448_contig15.bam SRR5046448_contig15.sam
samtools sort -o SRR5046448_contig15.sort.bam SRR5046448_contig15.bam

#run stringtie to get gtf files of transcript annotations
#for file in `dir -d *sort.bam` ; do

#    outdir=`echo "$file" |sed 's/.bam/.gtf/'`

#    /opt/stringtie/stringtie --rf -p 7 -o $outdir $file

#done
