
process pvog_DB {
  label 'noDocker'    
  if (params.cloudProcess) { 
    publishDir "${params.databases}/", mode: 'copy' 
  }
  else { 
    storeDir "${params.databases}/pvog" 
  }  

  output:
    tuple file("pvogs"), file("VOGTable.txt"), file("GenomeTable.txt"), file("VOGProteinTable.txt")
    

  script:
    """
    wget -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/hmmer_databases/pvogs.tar.gz && tar -zxvf pvogs.tar.gz
    rm pvogs.tar.gz
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/GenomeTable.txt
    wget -nH http://dmk-brain.ecn.uiowa.edu/pVOGs/downloads/VOGProteinTable.txt
    """
}