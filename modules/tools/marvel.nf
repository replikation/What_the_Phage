process marvel {
    label 'marvel'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(contig_bins) 
    output:
        tuple val(name), file("results_*.txt"), file(contig_bins)
    script:
        """
        # Marvel
        marvel_bins.py -i ${contig_bins} -t ${task.cpus} > results_\${PWD##*/}.txt
        """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/