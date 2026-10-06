process filter_completeness {
        label 'seqkit'
    input:
        tuple val(name), path(fasta), path(quality_summary)
    output:
        tuple val(name), path("${name}_completeness_filtered.fa"), emit: filtered_fasta_ch, optional: true
        tuple val(name), path("${name}_filter_too_strict.txt"), emit: filter_too_strict_ch, optional: true
    script:
        """
        total=\$(grep -c "^>" ${fasta})
        awk -F'\t' 'NR>1 && \$9+0 >= ${params.annotation_filter} {print "^" \$1 "\$"}' ${quality_summary} > contigs_to_keep.txt
        passed=\$(wc -l < contigs_to_keep.txt)
        if [ "\$passed" -gt 0 ]; then
            seqkit grep -r -f contigs_to_keep.txt ${fasta} > ${name}_completeness_filtered.fa
            [ -s ${name}_completeness_filtered.fa ] || passed=0
        fi
        if [ "\$passed" -eq 0 ]; then
            echo -e "CheckV completeness filter too strict\nSample: ${name}\nThreshold: completeness >= ${params.annotation_filter}\nResult: 0 of \${total} contigs passed.\nNo annotation was performed for this sample." > ${name}_filter_too_strict.txt
        fi
        """
    stub:
        """
        touch ${name}_completeness_filtered.fa
        """
}