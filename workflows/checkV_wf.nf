include { download_checkV_DB } from './process/checkV/download_checkV_DB'
include { checkV } from './process/checkV/checkV'
include { checkV_collect_data } from './process/checkV/checkV_collect_data'


workflow checkV_wf {
    take:   fasta_and_tool_results 
    main:   
            fasta = fasta_and_tool_results.map {it -> tuple(it[0],it[1])}
            // local storage via storeDir
            download_checkV_DB()
            // cloud storage via db_preload.exists()

            // tool prediction
            checkV(fasta, download_checkV_DB.out)
            //checkV_collect = checkV.out.map {it -> tuple(it[0],it[2])}
            checkV_collect_data(checkV.out.checkV_results_ch)
    emit:   checkV.out.sample_quality_ch
}

            /* filter_tool_names.out in identify_fasta_MSF is the info i need to parse into checkV overview 
            has tuple val(name), file("*.txt")
            
            each txt file can be present or not

            1.) parse this output into a "contig name", 1, 0" matrix still having the "value" infront of it

            2.) then i could do a join first bei val(name), an then combine by val(contigname) within the channels?
/* 
            3.) annoying ...

            */ 