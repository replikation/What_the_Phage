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
      
      # Marvel
      marvel_bins.py -i ${name}_contigs/ -t ${params.cpus} > results.txt
 
      # getting contig names               
            if grep -q ">" results.txt; then
              touch ${name}_\${rnd//0.}.list
              grep ">" results.txt | cut -f2 -d " " > pos-tmp.txt
              while IFS= read -r pos_ctg_list; 
              do
                while IFS= read -r samplename; 
                do
                 head -1 ${name}_contigs/\$samplename.fa >> ${name}_\${rnd//0.}.list
                 done < <(printf '%s\\n' "\$pos_ctg_list")
              done < pos-tmp.txt
            else 
             touch ${name}_\${rnd//0.}.list
            fi

      """
}


/*
.splitfasta()

set val(id), val(fasta) from clustering_multifastafile_ch.splitFasta( record: [id: true, seqString: true ])

*/