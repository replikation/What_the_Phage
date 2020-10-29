process filter_virnet {
    label 'altair'
    input:
        tuple val(name), file(results) 
    output:
        tuple val(name), file("virnet_*.txt")
    script:
        """
        # collect resultqs
        head -1 *.csv > all_virnet_results.txt     
        tail -q -n+2 *.csv  >> all_virnet_results.txt
      
        # extract correct positive contigs
        parse_virnet.py --input all_virnet_results.txt --output virnet_\${PWD##*/}.txt --filter ${params.vn_filter}  
        """
}


