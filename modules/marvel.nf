process marvel {
      publishDir "${params.output}/${name}/marvel", mode: 'copy', pattern: "${name}_*.list"
      label 'marvel'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    shell:
      """
      rnd=${Math.random()}
      mkdir fasta_dir_${name} 
      cp ${fasta} fasta_dir_${name}/
      # Marvel
      marvel_bins.py -i fasta_dir_${name} -t ${params.cpus} > results.txt
      # getting contig names
      filenames=\$(grep  "${name}\\." results.txt | cut -f2 -d " ")
      while IFS= read -r samplename ; do
       head -1 fasta_dir_${name}/\${samplename}.fa >> ${name}_\${rnd//0.}.list
      done < <(printf '%s\n' "\${filenames}")
      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/