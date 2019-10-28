process filter_deepvirfinder {
      publishDir "${params.output}/${name}/deepvirfinder", mode: 'copy', pattern: "deepvirfinder.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("deepvirfinder.txt")
    shell:
      """
      export LC_NUMERIC=en_US.utf-8
      sort  -g  -k4,4 *.txt | awk '\$4>=0.995' | awk '{ print \$1 }' | tail -n+2 > deepvirfinder.txt
      """
}