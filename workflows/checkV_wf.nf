include { download_checkV_DB } from './process/checkV/download_checkV_DB'
include { checkV } from './process/checkV/checkV'


workflow checkV_wf {
    take:   fasta_and_tool_results 
    main:   
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
            // local storage via storeDir
            if (!params.cloudProcess) { download_checkV_DB(); db = download_checkV_DB.out }
            // cloud storage via db_preload.exists()
            if (params.cloudProcess) {
                db_preload = file("${params.databases}/checkV/checkv-db-v0.6", type: 'dir')
                if (db_preload.exists()) { db = db_preload }
                else  { download_checkV_DB(); db = download_checkV_DB.out } 
            }
            // tool prediction
            checkV(fasta, download_checkV_DB.out)
}

            /* filter_tool_names.out in identify_fasta_MSF is the info i need to parse into checkV overview 
            has tuple val(name), file("*.txt")
            
            each txt file can be present or not

            1.) parse this output into a "contig name", 1, 0" matrix still having the "value" infront of it

            2.) then i could do a join first bei val(name), an then combine by val(contigname) within the channels?
/* 
            3.) annoying ...

            */ 