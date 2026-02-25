include { phabox2_host } from './process/phabox2_host_prediction'
include { download_genomad_DB } from './process/download_genomad_DB'
include { genomad_host_prediction } from './process/genomad_host_prediction'


workflow host_wf {
    take:   fasta
    main: 
            phabox2_host(fasta)
    


            //genomad_host_prediction(fasta, download_genomad_DB())
    



  //emit: testprofile.out.flatten().map { file -> tuple(file.simpleName, file) }

    //host: https://www.biorxiv.org/content/10.1101/2020.12.06.413476v1
}

