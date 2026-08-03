process bacphlip_lifecycle {
        publishDir "${params.output}/${name}/host_lifecycle/bacphlip", mode: 'copy' , pattern: "*_bacphlip_results.tsv"
        publishDir "${params.output}/${name}/host_lifecycle/bacphlip", mode: 'copy' , pattern: "*.tar.gz"
        //errorStrategy 'ignore'
        label 'bacphlip'
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path("${name}_lifecycle_bacphlip.tsv"), emit: bacphlip_lifecycle, optional: true
    script:
        """
        bacphlip -i ${fasta} --multi_fasta

        mv ${name}*BACPHLIP_DIR ${name}_bacphlip_dir
        mv ${name}*bacphlip ${name}_lifecycle_bacphlip.tsv
        mv ${name}*hmmsearch.tsv ${name}_bacphlip_hmmsearch.tsv
        



        
        tar -czf ${name}_bacphlip_dir.tar.gz ${name}_bacphlip_dir

        """
    stub:
        """
        touch ${name}_bacphlip_results.tsv
        """
}
