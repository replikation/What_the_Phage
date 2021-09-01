process metaphinder_own_DB {
    label 'metaphinder'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta)
        file(database)
    output:
        tuple val(name), file("${name}_*.list")
        // output collection stream
        tuple val(name), file("${name}_*.list"), file("${name}_*_blast.out")
    script:
        """
        rnd=${Math.random()}
        mkdir ${name}
        tar xzf ${database}
        MetaPhinder.py -i ${fasta} -o ${name} -d phage_blast_DB/phage_db
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