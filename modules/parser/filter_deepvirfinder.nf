process filter_deepvirfinder {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("deepvirfinder_*.txt")
    shell:
      """
      sort  -g  -k4,4 *.list | awk '\$3>=0.9' | awk '{ print \$1 }' | tail -n+2 > deepvirfinder_\${PWD##*/}.txt
      """
}