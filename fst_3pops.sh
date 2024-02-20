#!/bin/bash --login
###
#job name
#SBATCH --job-name=fst
#job stdout file
#SBATCH --output=./fst_out_%J
#job stderr file
#SBATCH --error=./fst_err_%J
#maximum job time in D-HH:MM
#SBATCH --time=0-12:00
#number of nodes
#SBATCH --nodes=1
#number of parallel processes (tasks)
#SBATCH --ntasks=10
#memory in Gb 
#SBATCH --mem=36G
#set working directory
#SBATCH --chdir=.

#load modules used by the script 
module purge
module load angsd/0.935

# pop bamlists
bamlist1='/scratch/scw2141/hedgehog_bams/fst/bamlist1.txt' # pop1 bamlist
bamlist2='/scratch/scw2141/hedgehog_bams/fst/bamlist2.txt' # pop2 bamlist
bamlist3='/scratch/scw2141/hedgehog_bams/fst/bamlist3.txt' # pop3 bamlist

# reference genome files
ref='/scratch/scw2141/hedgehog_bams/mEriEur2.1/GCA_950295315.1_mEriEur2.1_genomic.fa' # reference
auto='/scratch/scw2141/hedgehog_bams/mEriEur2.1/list_over_1mb.txt' # scaffolds
#auto='/scratch/scw2141/hedgehog_bams/mEriEur2.1/eg.txt' # scaffolds

# depth variables
max=20
min=3

##### main script #####

# Calculate site allele frequencies (per pop saf for each population)
angsd -b $bamlist1 -doSaf 1 -GL 1 -P 10 -anc $ref -rf $auto -out pop1 -minMapQ 30 -minQ 30 -setMinDepthInd $min
angsd -b $bamlist2 -doSaf 1 -GL 1 -P 10 -anc $ref -rf $auto -out pop2 -minMapQ 30 -minQ 30 -setMinDepthInd $min
angsd -b $bamlist3 -doSaf 1 -GL 1 -P 10 -anc $ref -rf $auto -out pop3 -minMapQ 30 -minQ 30 -setMinDepthInd $min

#Calculate the 2dsfs prior
realSFS pop1.saf.idx pop2.saf.idx -P 10 > pop1_pop2.ml
realSFS pop1.saf.idx pop3.saf.idx -P 10 > pop1_pop3.ml
realSFS pop2.saf.idx pop3.saf.idx -P 10 > pop2_pop3.ml

# calculate fst
realSFS fst index pop1.saf.idx pop2.saf.idx pop3.saf.idx -sfs pop1_pop2.ml -sfs pop1_pop3.ml -sfs pop2_pop3.ml -fstout pop1_pop2_pop3

# Get the global estimate
realSFS fst stats pop1_pop2_pop3.fst.idx > pop1_pop2_pop3.fst.global

# Sliding Window
realSFS fst stats2 pop1_pop2_pop3.fst.idx -win 1000000 -step 1000000 -type 0 > pop1_pop2_pop3.fst.window

