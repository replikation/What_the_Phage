process filter_tool_names {
    label 'ubuntu'
    input:
        tuple val(name), path(files)
    output:
        tuple val(name), path("*.txt")
        tuple val(name), path(files)
    script:
        """
        # simplify toolnames for R (its a quick fix for now)
          for x in *.tsv; do
            filename_simple=\$(echo "\${x}" | cut -f 1 -d "_")
            cat \${x} | cut -f1 > \${filename_simple}.txt
          done
        """
    stub:
        """
        touch dummy.txt
        """
}