## Slurm script for calculating fsts in angsd

script: fst_3pops.sh

3 bamlists, 1 per population, add individual bams accordingly

run with sbatch, check with squeue

*global is global fst estimate

*window is sliding window fst

Fst are reported in order p1p2, p1p3, p2p3

Caution results files will be overwritten each time script is run
