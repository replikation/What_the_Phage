process marvel {
      publishDir "${params.output}/${name}/marvel", mode: 'copy', pattern: "${name}.txt"
      label 'marvel'
      echo true
    input:
      set val(name), file(fasta) 
    output:
      set val(name), file("${name}.txt")
    shell:
      """
      mkdir fasta_dir_!{name} 
      
      cat !{fasta} | awk '{
            if (substr(\$0, 1, 1)==">") {filename=(substr(\$0,2) ".tmpFile")}
            print \$0 > filename }' 

      for filefasta in *.tmpFile; do
        filename=\$(echo "\${filefasta%.tmpFile}" | tr " " "_")
        mv "\${filefasta}" fasta_dir_!{name}/\${filename}.fa
      done

      marvel_bins.py -i fasta_dir_!{name} -t !{params.cpus} > results.txt
      grep "**" results.txt > !{name}.txt
      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/