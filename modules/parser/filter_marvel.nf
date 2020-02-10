process filter_marvel {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("marvel_*.txt")
    script:
      """
      rnd=${Math.random()}
      
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

      cat *.list | grep '>' | tr -d ">"  > marvel_\${rnd//0.}.txt
      """
}