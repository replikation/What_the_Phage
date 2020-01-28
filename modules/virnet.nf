process virnet {
      publishDir "${params.output}/${name}/virnet", mode: 'copy', pattern: "${name}_*.csv"
      label 'virnet'
    input:
      tuple val(name), file(fasta)
      file(dependencies) 
    output:
      tuple val(name), file("${name}_*.csv")
    script:
      """
      rnd=${Math.random()}
      cp -r ${dependencies}/* .
      chmod 777 *.py
      python3 virnet/predict.py --input_dim=500 --input=${fasta} --output=${name}_\${rnd//0.}.csv
      
      """
}

// the docker file multifractal/virnet:5.1 only contains  dependencies for virnet