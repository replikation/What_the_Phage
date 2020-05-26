process rvdb_DB {
  label 'noDocker'    
  if (params.cloudProcess) { 
    publishDir "${params.databases}/rvdb", mode: 'copy', pattern: "rvdb" 
  }
  else { 
    storeDir "${params.databases}/rvdb" 
  }  

  output:
    path("rvdb", type: 'dir')

  script:
    """
    wget -nH ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/viral-pipeline/hmmer_databases/rvdb.tar.gz && tar -zxvf rvdb.tar.gz
    rm rvdb.tar.gz
    """
}
