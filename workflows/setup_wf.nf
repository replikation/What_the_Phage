include { setup_container } from './setup/setup_container'
include { download_references_NCBI_identify } from './phage_identification_wf/process/sourmash/download_references' // phage references
include { phage_references_blastDB } from './phage_identification_wf/process/metaphinder_own_DB/phage_references_blastDB' // methaphinder own db
include { ppr_download_dependencies } from './phage_identification_wf/process/pprmeta/ppr_download_dependencies' 
include { sourmash_identify_DB_build } from './phage_identification_wf/process/sourmash/sourmash_identify_DB_build'
include { vibrant_download_DB } from './phage_identification_wf/process/vibrant/vibrant_download_DB'
include { virsorter_download_DB } from './phage_identification_wf/process/virsorter/virsorter_download_DB'
include { virsorter2_download_DB } from './phage_identification_wf/process/virsorter2/virsorter2_download_DB'
include { pvog_DB; vogtable_DB } from './annotation_and_taxonomy_wf/process/download_pvog_DB.nf'
include { download_checkV_DB } from './quality_control_wf/process/download_checkV_DB'
include { download_genomad_DB } from './annotation_and_taxonomy_wf/process/download_genomad_DB'


workflow setup_wf {
      
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
        if (!params.annotate_taxonomy) {
            download_references_NCBI_identify() // phage_references()
            ref_phages_DB = phage_references_blastDB (download_references_NCBI_identify.out)
            ppr_deps = ppr_download_dependencies()
            sourmash_DB = sourmash_identify_DB_build (download_references_NCBI_identify.out)
            vibrant_DB = vibrant_download_DB()
            virsorter_DB = virsorter_download_DB()
            virsorter2_DB = virsorter2_download_DB()
        }
        if (!params.identify) {
            pvog_DB = pvog_DB()
            vogtable_DB = vogtable_DB()
            checkV_DB = download_checkV_DB()
            genomad_db = download_genomad_DB()
        }
} 
/* 
        if (!params.annotate) {
            download_references_NCBI_identify() // phage_references()
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