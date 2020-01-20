process filter_virnet {
      publishDir "${params.output}/${name}/virnet", mode: 'copy', pattern: "virnet_*.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virnet_*.csv")
    script:
      """
      rnd=${Math.random()}


    sed 's|,|\t|g' ${name}_\${rnd//0.}.csv | awk '{if($6==1){print $2}}' > virnet_\${rnd//0.}.txt
      
      """
}

