process pharokka {
    publishDir "${params.output}/${name}/pharokka", mode: 'copy'
    errorStrategy 'ignore'
    label 'pharokka'
    input:
        tuple val(name), path(fasta)
    output: 
        tuple val(name), path("*_pharokka_out"), emit: pharokka_folder_ch optional true
    script:
        """

        pharokka.py -i ${fasta} -o ${name}_pharokka_out -t 10 -d /pharokka_v1.4.0_databases -t ${task.cpus} -f -p ${name}

        """
      stub:
        """
        mkdir stub_pharokka_out

        """
}


process pharokka_plotter {
    publishDir "${params.output}/${name}/pharokka", mode: 'copy'
    errorStrategy 'ignore'
    label 'pharokka'
    input:
        tuple val(name), path(fasta) , path(pharokka_annotation_out), path(checkv_results)
    output: 
         tuple val(name), path("pharokka_plots"), emit: annotation_map_ch optional true
    script:
        """
        ## split fasta to single contigs needed
        ## LC_ALL=C allow awk to use float numbers
        LC_ALL=C awk '{if(\$9>${params.plot_completeness} && \$2>5000)print\$1}' < ${checkv_results} |tail -n+2 > tmp_contigs_to_plot_${name}.tsv
        ## remove hypoithetical proteins from plot
        grep -v "name=hypothetical protein" ${pharokka_annotation_out}/${name}.gff > ${name}.gff
        mkdir pharokka_plots

        ## check if tmp file is empty
        if [ -s tmp_contigs_to_plot_${name}.tsv ]; then
            # The file is not-empty.
            ## plot
            while read LINE; do
                phage_plot_preliminary.py --gff3 ${name}.gff --name "\$LINE"_plot --contig \$LINE --ring1 salmon --ring2 skyblue --limit 30
            done < tmp_contigs_to_plot_${name}.tsv

        else
            # The file is empty.
            touch pharokka_plots/nothing_to_plot.txt
        fi
          
        mv *.jpg pharokka_plots
        mv *.svg pharokka_plots


        ##pharokka_plotter_parser.py --input ${pharokka_annotation_out}/${name}.gbk --contigs_to_extract tmp_contigs_to_plot.tsv
        ##cat *gbk > selected_${name}.gbk
        ##pharokka_multiplotter.py -g selected_${name}.gbk -o pharokka_plots --dpi 600 -f
        
        """
      stub:
        """
        mkdir pharokka_plots
        touch pharokka_plots/stub.png
        """
}

// pharokka_plotter.py -i all_pos_phage_filtered.fa -n all_pos_phage_annotation_map -o all_pos_phage_pharokka_out --interval 8000 --annotations 0.5 --plot_title 'test_Phage' -p all_pos_phage
// split fasta and keep contigname as a file name:awk 'BEGIN{RS=">";FS="\n"} NR>1{fnme=$1".fasta"; print ">" $0 > fnme; close(fnme);}' example.fasta