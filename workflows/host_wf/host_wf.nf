include { phabox2_host } from './process/phabox2_host_prediction'
include { download_iphop_DB } from './process/download_iphop_DB'
include { iphop } from './process/iphop_host_prediction'


workflow host_wf {
    take:   fasta
    main:   


            phabox2_host(fasta)

            if (params.iphop) { 

                        // local storage via storeDir
                        download_iphop_DB()
                        // host prediction
                        iphop(fasta, download_iphop_DB.out)
                        iphop_results = iphop.out
                        }
            else { iphop_results = Channel.from( [ 'deactivated', 'deactivated'] ) } 

    
            host_report_input = phabox2_host.out.concat(iphop_results)
                                      .filter { it != 'deactivated' } 
                                      .groupTuple()
    



  emit: host_report_input

    //host: https://www.biorxiv.org/content/10.1101/2020.12.06.413476v1
}

