#!/bin/sh
###############################################################
# pipeline for running BUSCO on BRAKER generated amino acid   #
# sequences                                                            #
# usage:                                                      #
#                                                             #
#      3_busco.sh $base_dir $CPU                             #
#                                                             #
###############################################################

cd $1
cd /scratch/annotation_output

cp /scratch/Botany2021NMGWorkshop/5.Annotation/Output/braker_ouput/augustus.hints.aa . 

docker run -u $(id -u) -v $(pwd):/busco_wd ezlabgva/busco:v5.1.2_cv1  \
busco -i augustus.hints.aa  \
--out busco_ouput -c 7  \
--auto-lineage --mode prot