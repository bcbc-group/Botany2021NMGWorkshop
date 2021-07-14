###################################################################################################################################
#.   You can find intermediate files from the below commands at /iplant/home/shared/Botany2020NMGWorkshop/annotation/2transfer    #
###################################################################################################################################
#copy the mikado output to your working directory
cd /scratch/annotation_output
cp /scratch/Botany2020NMGWorkshop/annotation/2transfer/mikado.loci.gff3 .

#count proteins in mikado output
awk '$3 == "gene" {print $0}' mikado.loci.gff3 |wc

#extract proteins from mikado output and remove ones with a single exon
/opt/gffread/gffread -U -J  -y mikado_prot.fasta -g contig_15.fasta  mikado.loci.gff3
mkdir orthofinder_input
mv mikado_prot.fasta orthofinder_input
cp orthofinder_input/mikado_prot.fasta orthofinder_input/mikado_prot2.fasta


#use orthofinder to remove redundancy; orthofinder_input contains two copies of mikado_prot.fasta, select one protein from each group to avoid overfitting
/opt/OrthoFinder/orthofinder -t 7 -a 7 -f orthofinder_input/

cut -f2 orthofinder_input/OrthoFinder/Results_May11/Orthogroups/Orthogroups.tsv |cut -f1 -d " " > groups.txt

git clone https://github.com/solgenomics/sgn-biotools.git

sed 's/ gene=mikado.*//g' orthofinder_input/mikado_prot.fasta > mikado_prot2.fasta

sgn-biotools/bin/fasta_extract.pl -f mikado_prot2.fasta -i groups.txt -z fasta -o mikado_proteins_training

#run scipio to get genbank file
/opt/scipio-1.4/scipio.1.4.1.pl --blat_output=prot.vs.genome.psl contig_15.fasta mikado_proteins_training.fasta > scipio.yaml #runs awhile

cat scipio.yaml | /opt/scipio-1.4/yaml2gff.1.4.pl > scipio.scipiogff

/usr/share/augustus/scripts/scipiogff2gff.pl --in=scipio.scipiogff --out=scipio.gff

cat scipio.yaml | /opt/scipio-1.4/yaml2log.1.4.pl > scipio.log

/usr/share/augustus/scripts/gff2gbSmallDNA.pl scipio.gff contig_15.fasta 1000 genes.raw.gb

etraining --species=generic --stopCodonExcludedFromCDS=true genes.raw.gb 2> train.err

cat train.err | perl -pe 's/.*in sequence (\S+): .*/$1/' > badgenes.lst

/usr/share/augustus/scripts/filterGenes.pl badgenes.lst genes.raw.gb > genes.gb

grep -c "LOCUS" genes.*

##################################################################
#.  These steps you will need to do on Atmosphere commandline.   #
##################################################################
#https://vcru.wisc.edu/simonlab/bioinformatics/programs/augustus/docs/tutorial2015/training.html
#iget -rPT /iplant/home/shared/Botany2020NMGWorkshop/Annotation

#randomly split set to training and test sets
/usr/share/augustus/scripts/randomSplit.pl genes.gb 200

grep -c LOCUS genes.gb*

#change permissions on folder so its contents can be edited
username=`whoami`
sudo chown $username /usr/share/augustus/config/species/

#create the new species conf
/usr/share/augustus/scripts/new_species.pl --species=Ugibba --AUGUSTUS_CONFIG_PATH /usr/share/augustus/config/

#train augustus
etraining --species=Ugibba genes.gb.train --stopCodonExcludedFromCDS=true

#look at new files created
ls -ort $AUGUSTUS_CONFIG_PATH/species/Ugibba

#test the training
augustus --species=Ugibba genes.gb.test | tee firsttest.out
tail -n 100 ../Botany2020NMGWorkshop/annotation/2transfer/firsttest.out 

#train snap (http://weatherby.genetics.utah.edu/MAKER/wiki/index.php/MAKER_Tutorial_for_GMOD_Online_Training_2014#Ab_Initio_Gene_Prediction) under "Training ab initio Gene Predictors"
#you can use the  same training set used in augustus
