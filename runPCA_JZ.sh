#!/bin/sh
## Pipeline for PCA
## Run on PMACS cluster

source $1 # arguments in template of runPCA_arg.txt
cd $dir

wd=${dir}/${out}
# Get sample IDs from annotation file and append population tag 'PRO'
awk 'FNR>1 {print $1,"PRO"}' $anno > $wd/pro_panel.tsv
## Concatenate sample ID and population text files from 1KGP and projected data
cat $now_id_pop $wd/pro_panel.tsv > $wd/now_pro_panel.tsv

## prepare parameters for generatePCA.sh file
cd $wd
touch pca_par
printf DIR=${wd} > pca_par
echo -e "\nVCF_FILENAME=${vcf}" >> pca_par
echo -e "\nPANEL_FILENAME=now_pro_panel.tsv" >> pca_par
echo -e "\nPOPLIST_FILENAME=${pops}" >> pca_par
echo -e "\ne2s_dir=${e2s_dir}" >> pca_par

cp $dir/1kg_pops ./1kg_pops

## Generate first [X] PCs with smartpca
echo "generatePCA.sh pca_par"
$dir/generatePCA.sh $wd/pca_par
