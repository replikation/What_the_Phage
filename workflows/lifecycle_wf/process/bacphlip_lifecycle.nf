process bacphlip_lifecycle {
        //errorStrategy 'ignore'
        label 'bacphlip'
    input:
        tuple val(name), path(fasta)
    output:
        tuple val(name), path("${name}_lifecycle_bacphlip.tsv"), emit: bacphlip_lifecycle, optional: true
    script:
        """

        if [ "\$(grep -c '^>' ${fasta} || true)" -gt 1 ]; then
            bacphlip -i ${fasta} --multi_fasta
            mv ${name}*BACPHLIP_DIR ${name}_bacphlip_dir
            tar -czf ${name}_bacphlip_dir.tar.gz ${name}_bacphlip_dir
        else
            bacphlip -i ${fasta}
        fi

        mv ${name}*bacphlip ${name}_lifecycle_bacphlip.tsv
        mv ${name}*hmmsearch.tsv ${name}_bacphlip_hmmsearch.tsv


        """
    stub:
        """
        touch ${name}_bacphlip_results.tsv
        """
}
