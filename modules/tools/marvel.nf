process marvel {
      label 'marvel'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("results_*.txt")
    shell:
      """
      rnd=${Math.random()}
      
      # Marvel
      marvel_bins.py -i ${name}_contigs/ -t ${params.cpus} > results_\${rnd//0.}.txt
      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/