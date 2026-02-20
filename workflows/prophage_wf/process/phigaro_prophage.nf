process phigaro_prophage {
    publishDir "${params.output}/${name}/prophage/phigaro", mode: 'copy'
    label 'phigaro'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("${name}_prophage_phigaro.tsv"), emit: phigaro_prophage_ch, optional: true
        tuple val(name), path("${name}_prophage_phigaro.html"), emit: phigaro_prophage_ch_html, optional: true
    script:
        """
        phigaro -f ${fasta} -o ${name}_prophage_phigaro -t ${task.cpus} -d --config /root/.phigaro/config.yml -e html tsv
        
        """
    stub:
        """
        touch ${name}_prophage_phigaro.tsv
        touch ${name}_prophage_phigaro.html
        """
}

// echo "" will attach  the new line to the last line 
// this way, it will produce no error when we collect all results in with samtools
// pos_phage_0$
// pos_phage_3$
// pos_phage_4$
// pos_phage_5$
// pos_phage_6$
// pos_phage_7$
// pos_phage_8$
// pos_phage_9
//

// removes empty line : sed '${/^$/d}'


//awk -v score="1" -F"," 'BEGIN { OFS = "\\t" } {$2=score; print}'