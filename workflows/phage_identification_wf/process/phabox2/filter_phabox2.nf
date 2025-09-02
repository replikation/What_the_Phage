process filter_phabox2_identify {
  	label 'ubuntu'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("phabox2_identify_*.tsv")
    shell:
        """
        tail -n+2 *_phamer_prediction_*.tsv | sort -gr -k5  | awk '{ print \$1, \$5}' OFS='\\t' > > phabox2_identify_\${PWD##*/}.tsv
        """
}

// sort for phamer score between 0 and 1.0