process filter_tool_names {
    publishDir "${params.output}/${name}/identified_contigs_by_tools/", mode: 'copy'
    label 'ubuntu'
    input:
        tuple val(name), file(files)
    output:
        tuple val(name), file("*.txt")
    script:
        """
        # simplify toolnames for R (its a quick fix for now)
          for x in *.txt; do
            filename_simple=\$(echo "\${x}" | cut -f 1 -d "_")
            mv \${x} \${filename_simple}.txt
          done
        """
}