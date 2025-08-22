process metaphinder {
    label 'metaphinder'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta) 
    output:
        tuple val(name), file("${name}_*.list")
        // output collection stream
        tuple val(name), file("${name}_*.list"), file("${name}_*_blast.out")
    script:
        """
        mkdir ${name}
        MetaPhinder.py -i ${fasta} -o ${name} -d /MetaPhinder/database/ALL_140821_hr
        mv ${name}/output.txt ${name}_\${PWD##*/}.list
        mv ${name}/blast.out ${name}_\${PWD##*/}_blast.out
        """
    stub:
        """
        echo "#contigID       classification  ANI [%] merged coverage [%]     number of hits  size[bp]" > ${name}_\${PWD##*/}.list
        echo "pos_phage_0     phage   80.754  96.97   172     146647" >> ${name}_\${PWD##*/}.list
        touch ${name}_\${PWD##*/}_blast.out
        """
}



