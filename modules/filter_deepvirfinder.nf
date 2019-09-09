process filter_deepvirfinder {
      publishDir "${params.output}/${name}/deepvirfinder", mode: 'copy', pattern: "${name}-filtered.txt"
      label 'ubuntu'
    input:
      set val(name), file(results) 
    output:
      set val(name), file("${name}-filtered.txt")
    shell:
      """
      export LC_NUMERIC=en_US.utf-8
      sort  -g  -k4,4 *.txt | awk '\$4>=0.995' | awk '{ print \$1 }' | tail -n+2 > !{name}-filtered.txt
      """
}