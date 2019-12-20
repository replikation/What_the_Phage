process download_references {
        if (params.cloudProcess) {
           publishDir "${params.cloudDatabase}/references/", mode: 'copy', pattern: "phage_references.fa"
        }
        else {
           storeDir "nextflow-autodownload-databases/references/"
        }
       label 'noDocker'    
      output:
        file("phage_references.fa")
      script:
        """
        wget http://147.8.185.62/VirMiner/downloads/phage_genome/public_phage_genomes.fasta
        cat *.fasta > phage_references.fa
        """
    }