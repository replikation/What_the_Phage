process samtools {
        publishDir "${params.output}/${name}/phage_positive_contigs", mode: 'copy', pattern: "${name}_positive_contigs.fa"
        label 'samtools'
    input:
        tuple val(name), path(file), path(list)
    output:
        tuple val(name), path("${name}_positive_contigs.fa")
    script:
        """
        cat ${list} | sort | uniq > tmp_allctgs.txt
        cat ${file} > all.fasta

        # get samtools but ignore "samtool fails"
        while read fastaheader; do    
            if grep -qw ">\$fastaheader" all.fasta; then
                samtools faidx all.fasta \$fastaheader >> ${name}_positive_contigs.fa
            else
                echo "\$fastaheader not found" >> error_code_samtools.txt
            fi
        done < tmp_allctgs.txt

        # old command
        # xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_positive_contigs.fa
        """
}

process samtools_fastq {
        publishDir "${params.output}/${name}/phage_positive_contigs", mode: 'copy', pattern: "${name}_positive_contigs.fa"
        label 'samtools'
    input:
        tuple val(name), path(file), path(list)
    output:
        tuple val(name), path("${name}_positive_contigs.fa")
    script:
        """
        cat ${list} | sort | uniq > tmp_allctgs.txt
        cat ${file} > all.fasta
        
        # get samtools but ignore "samtool fails"
        while read fastaheader; do    
            if grep -qw ">\$fastaheader" all.fasta; then
                samtools faidx all.fasta \$fastaheader >> ${name}_positive_contigs.fa
            else
                echo "\$fastaheader not found" >> error_code_samtools.txt
            fi
        done < tmp_allctgs.txt

        # old command
        # xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_positive_contigs.fa
      """
}