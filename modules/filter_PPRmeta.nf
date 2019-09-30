process filter_PPRmeta {
      publishDir "${params.output}/${name}/PPRmeta", mode: 'copy', pattern: "PPRmeta.txt"
      label 'ubuntu'
    input:
      set val(name), file(results) 
    output:
      set val(name), file("PPRmeta.txt")
    shell:
      """
       tail -n+2 !{results} | grep 'phage'| cut -d ' ' -f1 > PPRmeta.txt
      """
}