include { phabox2_host } from './process/phabox2_host_prediction'
include { download_iphop_DB } from './process/download_iphop_DB'
include { iphop_host_prediction } from './process/iphop_host_prediction'


workflow host_wf {
    take:   fasta
    main:   

            phabox2_host(fasta)
            host_phabox2 = phabox2_host.out.phabox2_annotation

            if (params.iphop) { 

                        // local storage via storeDir
                        download_iphop_DB()
                        // host prediction
                        iphop_host_prediction(fasta, download_iphop_DB.out)
                        host_iphop = iphop_host_prediction.out.iphop_host_genus_ch
                        iphop_out  = iphop_host_prediction.out.iphop_Host_folder_ch
                        }
            else { host_iphop = Channel.empty() 
                    iphop_out = Channel.empty() } 

    
            host_report_input = phabox2_host.out.concat(host_iphop)
                                      .groupTuple()
    




  emit:
    host_report_input = host_report_input
    phabox2_host_ch = host_phabox2
    host_iphop_ch = host_iphop
    iphop_out_ch = iphop_out

    //host: https://www.biorxiv.org/content/10.1101/2020.12.06.413476v1
}

