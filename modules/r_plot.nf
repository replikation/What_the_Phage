process r_plot {
    label 'ggplot2'
    input:
        tuple val(name), file(files)
    output:
        tuple val(name), file("phage-distribution.pdf") optional true
        tuple val(name), file("results.txt") optional true
    script:
        """
        linenumbers=\$(cat *.txt | wc -l)
        if (( \${linenumbers} == 0 )) ; then
          echo "No Phages found" > results.txt
        else
          # parser script in xargs
            convert.sh
          # plotting
            heatmap.R summary.csv
        fi
        """
}