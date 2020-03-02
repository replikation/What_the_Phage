process marvel {
      label 'marvel'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(contig_bins) 
    output:
      tuple val(name), file("results_${random}.txt"), file(contig_bins)
    script:
      """
      
      
      # Marvel
      marvel_bins.py -i ${contig_bins} -t ${params.cpus} > results_${random}.txt
      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/