process virfinder {
    label 'virfinder'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("${name}_*.list")
    script:
        """
        virfinder_execute.R ${fasta} 
        cp results.txt ${name}_\${PWD##*/}.list
        """
    stub:
        """
        echo "          name length     score      pvalue" > ${name}_\${PWD##*/}.list
        echo "6  pos_phage_5  43293 0.9926088 0.001940335" >> ${name}_\${PWD##*/}.list
        """
}