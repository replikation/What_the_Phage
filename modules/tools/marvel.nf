process marvel {
      label 'marvel'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
       // output collection stream
      tuple val(name), file("results_*.txt")
    shell:
      """
      rnd=${Math.random()}
      
      # Marvel
      marvel_bins.py -i ${name}_contigs/ -t ${params.cpus} > results_\${rnd//0.}.txt
 
      # getting contig names   
      touch ${name}_\${rnd//0.}.list

        if grep -q ">" results_\${rnd//0.}.txt; then
            grep ">" results_\${rnd//0.}.txt | cut -f2 -d " " > temporary.file
          while IFS= read -r pos_ctg_list ; do
            while IFS= read -r samplename ; do
              head -1 ${name}_contigs/\$samplename.fa >> ${name}_\${rnd//0.}.list
            done < <(printf '%s\\n' "\$pos_ctg_list")
          done < temporary.file
        fi
      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/