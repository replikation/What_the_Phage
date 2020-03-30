process filter_marvel {
      label 'ubuntu'
    input:
      tuple val(name), file(results), file(bin_dir)
    output:
      tuple val(name), file("marvel_*.txt")
    script:
      """
      
      # getting contig names   

        if grep -q ">" ${results}
        then
            grep ">" ${results} | cut -f2 -d " " > list_of_binnames.file
              while IFS= read -r positive_contig ; do
                  head -1 ${bin_dir}/\${positive_contig}.fa | tr -d ">" >> marvel_\${PWD##*/}.txt
              done < list_of_binnames.file
        else
          touch marvel_\${PWD##*/}.txt
        fi
      """
}