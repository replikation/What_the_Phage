include { filter_tool_names } from './process/prepare_results_wf/filter_tool_names'
include { upsetr_plot } from './process/prepare_results_wf/upsetr'

workflow prepare_results_wf {
    take:   results
    main: 
                        
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])        

    //emit: prepare_results_wf_output // val(name), path(fasta), path(scores_by_tools)
    //emit: output = fasta_validation_wf.out.join(results)  // val(name), path(fasta), path(scores_by_tools)
}