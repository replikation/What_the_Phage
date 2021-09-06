include { setup_container } from './process/setup/setup_container'
include { download_references } from './process/sourmash/download_references' // phage references
include { phage_references_blastDB } from './process/metaphinder_own_DB/phage_references_blastDB' // methaphinder own db
include { ppr_download_dependencies } from './process/pprmeta/ppr_download_dependencies' 
include { sourmash_download_DB } from './process/sourmash/sourmash_download_DB'
include { vibrant_download_DB } from './process/vibrant/vibrant_download_DB'
include { virsorter_download_DB } from './process/virsorter/virsorter_download_DB'
include { virsorter2_download_DB } from './process/virsorter2/virsorter2_download_DB'
include { pvog_DB; vogtable_DB } from './process/phage_annotation/download_pvog_DB'
include { download_checkV_DB } from './process/checkV/download_checkV_DB'


workflow setup_wf {
    take:   
    main:       
        // docker
        if (workflow.profile.contains('docker')) {
            config_ch = Channel.fromPath( workflow.projectDir + "/configs/container.config" , checkIfExists: true)
            setup_container(config_ch)
        }
        // singularity
        if (workflow.profile.contains('singularity')) {
            config_ch2 = Channel.fromPath( workflow.projectDir + "/configs/container.config" , checkIfExists: true)
            setup_container(config_ch2)
        }

        // databases
        if (!params.annotate) {
            download_references() // phage_references()
            ref_phages_DB = phage_references_blastDB (download_references.out)
            ppr_deps = ppr_download_dependencies()
            sourmash_DB = sourmash_download_DB (download_references.out)
            vibrant_DB = vibrant_download_DB()
            virsorter_DB = virsorter_download_DB()
            virsorter2_DB = virsorter2_download_DB()
        }
        if (!params.identify) {
            pvog_DB = pvog_DB()
            vogtable_DB = vogtable_DB()
            checkV_DB = download_checkV_DB()
        }
} 
/* 
        if (!params.annotate) {
            download_references() // phage_references()
            ref_phages_DB = phage_references_blastDB (phage_references.out)
            ppr_deps = ppr_download_dependencies()
            sourmash_DB = sourmash_download_DB (phage_references.out)
            vibrant_DB = vibrant_download_DB()
            virsorter_DB = virsorter_download_DB()
            virsorter2_DB = virsorter2_download_DB()
        }
        if (!params.identify) {
            pvog_DB = pvog_DB()
            vogtable_DB = vogtable_DB()
            checkV_DB = download_checkV_DB() */