process filter_deepvirfinder {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("deepvirfinder_*.txt")
    shell:
      """
      tail -n+2 *.list | sort -g  -k4,4  | awk '\$3>=${params.dv_filter}' | awk '{ print \$1 }'  > deepvirfinder_\${PWD##*/}.txt
      """
}