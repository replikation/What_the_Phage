process filter_virnet {
    label 'altair'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("virnet_*.tsv")
    script:
        """
        # collect resultqs
        head -1 *.csv > all_virnet_results.txt     
        tail -q -n+2 *.csv  >> all_virnet_results.txt
      
        # extract correct positive contigs
        parse_virnet.py --input all_virnet_results.txt --output virnet_\${PWD##*/}.tsv
        """
}
