process virnet {
      publishDir "${params.output}/${name}/virnet", mode: 'copy', pattern: "${name}_*.csv"
      label 'virnet'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.csv")
    script:
      """
      rnd=${Math.random()}
      
      

    python3 predict.py --input_dim=500 --input=${fasta} --output=${name}_\${rnd//0.}.csv

      """
}