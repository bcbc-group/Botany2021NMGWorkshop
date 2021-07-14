#generate control files
maker -CTL

#edit the input control file
emacs maker_opts.ctl
#genome=contig_15_masked.fasta
#protein=uniprot_sprot_plants.fasta
#model_org= #all
#repeat_protein= #/opt/maker/data/te_proteins.fasta
#augustus_species=Ugibba
#pred_gff=mikado.loci.gff3
#est2genome=0
#protein2genome=0

#run maker
#screen -L mpirun -np 7 maker -base maker1       #will take awhile - output on CyVerse data store under /iplant/home/shared/Botany2020NMGWorkshop/annotation/2transfer/contig_15.maker.output
screen  /opt/maker/bin/maker -base maker1       #will take awhile - output on /scratch/Botany2020NMGWorkshop/annotation/2transfer/contig_15.maker.output/

#make a gff3 files from maker results
ln -s /scratch/Botany2020NMGWorkshop/annotation/2transfer/contig_15.maker.output/ .
cd contig_15.maker.output
/opt/maker/bin/gff3_merge -d maker1_master_datastore_index.log
/opt/maker/bin/gff3_merge -g -o maker1_models.gff -d maker1_master_datastore_index.log

#make a protein file from maker output
/opt/gffread/gffread -g ../contig_15.fasta -y maker1_proteins.fasta maker1_models.gff

#run BUSCO
#iget -rPT /iplant/home/shared/Botany2020NMGWorkshop/embryophyta_odb9

docker run -u $(id -u) -v $(pwd):/busco_wd ezlabgva/busco:v5.1.2_cv1 busco -i maker1_proteins.fasta --out Ugibba_maker1 -c 7 --auto-lineage --mode prot
