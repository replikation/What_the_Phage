workflow identify_results {
    take:   //tool outputs
    main: 
        // input filter  
        fasta_validation_wf(fasta)

        // gather results
            results =   virsorter_wf(fasta_validation_wf.out, virsorter_DB)
                        .concat(virsorter2_wf(fasta_validation_wf.out, virsorter2_DB))
                        .concat(virsorter_virome_wf(fasta_validation_wf.out, virsorter_DB))
                        // depracted due to file size explosin -> .concat(marvel_wf(fasta_validation_wf.out))      
                        .concat(sourmash_wf(fasta_validation_wf.out, sourmash_DB))
                        .concat(metaphinder_wf(fasta_validation_wf.out))
                        .concat(metaphinder_own_DB_wf(fasta_validation_wf.out, ref_phages_DB))
                        .concat(deepvirfinder_wf(fasta_validation_wf.out))
                        .concat(virfinder_wf(fasta_validation_wf.out))
                        .concat(pprmeta_wf(fasta_validation_wf.out, ppr_deps))
                        .concat(vibrant_wf(fasta_validation_wf.out, vibrant_DB))
                        .concat(vibrant_virome_wf(fasta_validation_wf.out, vibrant_DB))
                        .concat(virnet_wf(fasta_validation_wf.out))
                        .concat(phigaro_wf(fasta_validation_wf.out))
                        .concat(seeker_wf(fasta_validation_wf.out))
                        .filter { it != 'deactivated' } // removes deactivated tool channels
                        .groupTuple()
                                               
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])        

    emit:   output = fasta_validation_wf.out.join(results)  // val(name), path(fasta), path(scores_by_tools)