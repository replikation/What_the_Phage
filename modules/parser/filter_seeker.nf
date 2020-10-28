process filter_seeker {
  	label 'ubuntu'
    input:
        tuple val(name), file(results) 
    output:
        tuple val(name), file("seeker_*.txt")
    shell:
        """
        tail -n+2 *.list | sort -gr -k3  | awk '\$3>=${params.sk_filter}' | awk '{ print \$1 }'  > seeker_\${PWD##*/}.txt
        """
}

/* 
raw output:

$ predict-metagenome example_input/PGE.txt > PGE.out.tsv
$ cat PGE.out.tsv
name    prediction      score
MH356729.1      Phage   0.85
LC333428.1      Phage   0.79
MK903728.1      Phage   0.94
MN016939.1      Bacteria        0.34
MN095770.1      Phage   0.82
MN095772.1      Phage   0.84
MN176219.1      Phage   0.52
MN310548.1      Phage   0.62
MN379739.1      Phage   0.82
MN419153.1      Phage   0.89

"Sequences with scores above 0.5 are predicted phages, 
while sequences with scores below 0.5 are predicted bacteria."

*/

