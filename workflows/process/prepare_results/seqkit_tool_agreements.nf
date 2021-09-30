process seqkit_tool_agreements {
        publishDir "${params.output}/${name}/tool_agreements_per_contig/", mode: 'copy' , pattern: "*_tool_match/*.fasta"
/*         errorStrategy 'ignore' */
        label 'seqkit'
    input:
        tuple val(name), path(toolagreement_per_contig), path(fasta)
    output:
        tuple val(name), path("*_tool_match/*.fasta")
    script:
        """

            toolagreements=\$(awk '{print \$2}' ${toolagreement_per_contig} |sort -u )
            for i in \$toolagreements; do
                mkdir ""\$i"_tool_match"
                echo ""\$i"_tool(s)_match"
                awk -v r=\$i  '\$2 == r' ${toolagreement_per_contig} | awk '{print \$1}' > "\$i"_tool_match.txt 
                seqkit faidx ${fasta} --infile-list "\$i"_tool_match.txt >> ${name}_"\$i"_tools_match.fasta
                mv ${name}_"\$i"_tools_match.fasta  "\$i"_tool_match
            done

        """
    stub:
        """
        mkdir x_tools_match
        touch x_tools_match/x_tools_match.fasta
        """
}



    // input:
    //     tuple val(name), file(file), file(list)
    // output:
    //     tuple val(name), file("${name}_positive_contigs.fa")
    // script:
    //     """
    //     cat ${list} | sort | uniq > tmp_allctgs.txt
    //     cat ${file} > all.fasta
    //     # get samtools but ignore "samtool fails"
    //     while read fastaheader; do    
    //         if grep -qw ">\$fastaheader" all.fasta; then
    //             samtools faidx all.fasta \$fastaheader >> ${name}_positive_contigs.fa
    //         else
    //             echo "\$fastaheader not found" >> error_code_samtools.txt
    //         fi
    //     done < tmp_allctgs.txt
    //     # old command
    //     # xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_positive_contigs.fa