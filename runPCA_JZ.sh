#!/bin/sh
## Pipeline for PCA
## Run on PMACS cluster

source $1 # arguments in template of runPCA_arg.txt
cd $dir

if $filter;
  then
    # Filter VCFs by SNPs specific to trait
    now_vcf2=${now_vcf%%.*}_${trait}.vcf.gz
    bcftools view -R $snps -O z $now_vcf > $now_vcf2
    bcftools index $now_vcf2

    pro_vcf2=${pro_vcf%%.*}_${trait}.vcf.gz
    bcftools view -R $snps -O z $pro_dir/$pro_vcf > $dir/$pro_vcf2
    bcftools index $pro_vcf2
  else
    # Use all SNPs on capture array
    now_vcf2=$now_vcf
    pro_vcf2=$pro_dir/$pro_vcf
fi

wd=${dir}/${out}
# Get sample IDs from annotation file and append population tag 'PRO'
awk 'FNR>1 {print $1,"PRO"}' $anno > $wd/pro_panel.tsv
## Concatenate sample ID and population text files from 1KGP and shotgun data.
cat $now_id_pop $wd/anc_panel.tsv > $wd/now_pro_panel.tsv

## Combine VCFs of present-day humans and projected humans
echo "bcftools merge -O z $now_vcf2 $pro_vcf2 > $wd/${trait}.vcf.gz"
bcftools merge -O z $now_vcf2 $pro_vcf2 > $wd/${trait}.vcf.gz

## prepare parameters for generate PCA file
cd $wd
touch pca_par
printf DIR=${wd} > pca_par
echo -e "\nVCF_FILENAME=${trait}.vcf.gz" >> pca_par
echo -e "\nPANEL_FILENAME=now_pro_panel.tsv" >> pca_par
echo -e "\nPOPLIST_FILENAME=${pops}" >> pca_par
echo -e "\ne2s_dir=${e2s_dir}" >> pca_par

cp $dir/1kg_pops ./1kg_pops

## Generate first [X] PCs with smartpca
echo "generatePCA.sh pca_par"
$dir/generatePCA.sh $wd/pca_par
