process phigaro_prophage {
    publishDir "${params.output}/${name}/prophage/phigaro", mode: 'copy'
    publishDir "${params.output}/${name}/raw_data/", mode: 'copy', pattern: "${name}_phigaro_prophage_output.tar.gz"
    label 'phigaro'
    //errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("${name}_prophage_phigaro.tsv"), emit: phigaro_prophage_ch, optional: true
        tuple val(name), path("${name}_prophage_phigaro.html"), emit: phigaro_prophage_ch_html, optional: true
    script:
        """
        phigaro -f ${fasta} -o ${name}_prophage_phigaro -t ${task.cpus} -d --config /root/.phigaro/config.yml -e html tsv

        # zip for export
        tar -czf ${name}_phigaro_prophage_output.tar.gz ${name}_prophage_phigaro.tsv ${name}_prophage_phigaro.html 
        
        """
    stub:
        """
        touch ${name}_prophage_phigaro.tsv
        touch ${name}_prophage_phigaro.html
        """
}