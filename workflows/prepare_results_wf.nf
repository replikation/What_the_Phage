include { filter_tool_names } from './process/prepare_results/filter_tool_names'
include { upsetr_plot } from './process/prepare_results/upsetr'
include { hue_heatmap } from './process/prepare_results/hue_heatmap'
include { contigs_by_tools } from './process/prepare_results/contigs_by_tools'
include { seqkit_tool_agreements } from './process/prepare_results/seqkit_tool_agreements'


workflow prepare_results_wf {
    take:   results
            fasta
    main:                         
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])
            contigs_by_tools(results)

        // markdown report collecter
            heatmap_table_markdown_input = contigs_by_tools.out.overview_ch//.join(contigs_by_tools.out.tool_agreements_per_contig_ch)
            upsetr_plot_markdown_input = upsetr_plot.out
    
    emit:   heatmap_table_markdown_input
            upsetr_plot_markdown_input
}