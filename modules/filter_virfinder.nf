process filter_virfinder {
      publishDir "${params.output}/${name}/virfinder", mode: 'copy', pattern: "virfinder.txt"
      label 'ubuntu'
    input:
      set val(name), file(results) 
    output:
      set val(name), file("virfinder.txt")
    shell:
      """
        sort  -k5,5 !{results} | awk '\$5>=0.75' | awk '{ print \$2 }' > virfinder.txt
      """
}