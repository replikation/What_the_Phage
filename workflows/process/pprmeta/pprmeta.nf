process pprmeta {
    label 'pprmeta'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
        file(depts) 
    output:
        tuple val(name), path("${name}_*.csv")
    script:
        """
        cp ${depts}/* .
        ./PPR_Meta ${fasta} ${name}_\${PWD##*/}.csv
        """
    stub:
        """
        echo "Header,Length,phage_score,chromosome_score,plasmid_score,Possible_source" > ${name}_\${PWD##*/}.csv
        echo "pos_phage_0,146647,0.896779561895599,0.0204569467278726,0.0827634909322214,phage" >> ${name}_\${PWD##*/}.csv
        """
}

 // .fasta is not working here. has to be .fa
 // need to implement this so its fixed 
