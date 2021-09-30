process seeker {
    label 'seeker'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta) 
    output:
        tuple val(name), file("${name}_*.list")
    script:
        """  
        predict-metagenome ${fasta} > ${name}.tsv
        cp ${name}.tsv ${name}_\${PWD##*/}.list
        """
    stub:
        """
        echo "name	prediction	score" > ${name}_\${PWD##*/}.list
        echo "pos_phage_0	Phage	0.82" >> ${name}_\${PWD##*/}.list
        """
}
