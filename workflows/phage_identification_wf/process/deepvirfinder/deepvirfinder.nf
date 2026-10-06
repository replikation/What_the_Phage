process deepvirfinder {
    label 'deepvirfinder'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta) 
    output:
        tuple val(name), file("${name}_*.list")
    script:
        """  
        dvf.py -c ${task.cpus} -i ${fasta} -o ${name}
        cp ${name}/*.txt ${name}_\${PWD##*/}.list
        """
    stub:
        """
        echo "name    len     score   pvalue" > ${name}_\${PWD##*/}.list
        echo "pos_phage_6     43851   0.9999517202377319      0.0011518996903089357" >> ${name}_\${PWD##*/}.list
        """
}