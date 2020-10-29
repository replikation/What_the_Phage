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
}
