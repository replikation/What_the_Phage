process filter_virsorter_virome {
    label 'ubuntu'
    input:
        tuple val(name), path(results), path(dir)
    output:
        tuple val(name), path("virsorter-virome_*.tsv")
    shell:
        """
        while IFS= read -r line; do
            if  [[ "\$line" == *-cat_1 ]]  ; then
                echo "\$line,1" >> virsorter_phage.tsv

            elif [[ "\$line" == *-cat_2 ]] ; then
                echo "\$line,0.5" >> virsorter_phage.tsv

            elif [[ "\$line" == *-cat_3 ]] ; then
                echo "\$line,0" >> virsorter_phage.tsv

            elif [[ "\$line" == *-cat_4 ]] ; then
                echo "\$line,1" >> pro_phage_virsorter.tsv

            elif [[ "\$line" == *-cat_5 ]] ; then
                echo "\$line,0.5" >> pro_phage_virsorter.tsv

            elif [[ "\$line" == *-cat_6 ]] ; then
                echo "\$line,0" >> pro_phage_virsorter.tsv
            fi
        done < virsorter_categorized_contigs_*.list

        grep ">" virsorter_phage.tsv | \\
        sed -e s/\\>VIRSorter_//g | \\
        sed -e s/\\-cat_[1-3]//g | \\
        awk -F, '{print \$1, \$2}' OFS="\\t" > virsorter-virome_\${PWD##*/}.tsv
        rm virsorter_phage.tsv
        """
}
