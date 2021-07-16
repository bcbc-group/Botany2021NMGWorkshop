mkdir SAM
mkdir bam
mkdir sorted_bam
mkdir Transcriptome



#Run cutadapt, need to tell it where the raw sequencing files are
#if [[ $start_step -le 1 ]]
#then
#	for file in Illumina_data_for_SNPs/*.fastq.gz
#	do
#		name=`basename $file .fastq.gz`
#		echo "Running fastp on $name"
#		forward=$name".fastq.gz"
#		/media/kcn2/12TBarray/jacob/Installed_programs/fastp -i Illumina_data_for_SNPs/$forward -o /scratch/Botany2020NMGWorkshop/raw_data/Ugibba/transcriptome/$forward -z 4 --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -q 20 --length_required 100 --thread 3
#	done
#fi


#to index a fasta file
#bwa index Ugibba_pruned_assembly.fasta

#Read group information starts with "@RG
#ID: is unique identifier of the samples, for now doing the sample name and the barcode info
#SM: is the sample name
#PL: is the sequencing equipment, in almost all cases this will be Illumina
#PU: is the run identifier, the lane, followed by the specific barcode of the sample
#LB: is the library count


/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:bladderR1\tSM:Rep1\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_bladder_Sample1_subset.fastq.gz > SAM/Ugibba_bladder_Sample1_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:rhizoidR1\tSM:Rep1\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_rhizoid_Sample1_subset.fastq.gz > SAM/Ugibba_rhizoid_Sample1_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:stemR2\tSM:Rep2\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_stem_Sample2_subset.fastq.gz > SAM/Ugibba_stem_Sample2_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:leafR3\tSM:Rep3\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_leaf_Sample3_subset.fastq.gz > SAM/Ugibba_leaf_Sample3_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:bladderR3\tSM:Rep3\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_bladder_Sample3_subset.fastq.gz > SAM/Ugibba_bladder_Sample3_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:stemR3\tSM:Rep3\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_stem_Sample3_subset.fastq.gz > SAM/Ugibba_stem_Sample3_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:rhizoidR3\tSM:Rep3\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_rhizoid_Sample3_subset.fastq.gz > SAM/Ugibba_rhizoid_Sample3_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:leafR1\tSM:Rep1\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_leaf_Sample1_subset.fastq.gz > SAM/Ugibba_leaf_Sample1_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:stemR1\tSM:Rep1\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_stem_Sample1_subset.fastq.gz > SAM/Ugibba_stem_Sample1_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:leafR2\tSM:Rep2\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_leaf_Sample2_subset.fastq.gz > SAM/Ugibba_leaf_Sample2_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:rhizoidR2\tSM:Rep2\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_rhizoid_Sample2_subset.fastq.gz > SAM/Ugibba_rhizoid_Sample2_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:shootstraps\tSM:Rep\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_shootstraps_subset.fastq.gz > SAM/Ugibba_shootstraps_subset.sam
/opt/bwa-0.7.17/bwa mem -t 4 -R "@RG\tID:veg\tSM:Rep\tPL:HiSeq\tPU:HTNMKDSXX\tLB:RNA-Seq" Ugibba_pruned_assembly.fasta Ugibba_vegetative_subset.fastq.gz > SAM/Ugibba_vegetative_subset.sam





#convert SAM to BAM for sorting

for file in SAM/*.sam
do
	echo "Convert $file to to BAM"
	name=`basename $file .sam`
	samtools view -S -b $file > bam/$name.bam
	rm $file
done

#Sort BAM for SNP calling
for file in bam/*.bam
do
	echo "Sort $file"
	name=`basename $file .bam`
	readid=$name
	samtools sort -o sorted_bam/$readid.bam $file
	rm $file
done



hostname
