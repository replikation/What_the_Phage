process virnet {
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
      python3 virnet/predict.py --input_dim=100 --input=${fasta} --output=${name}_\${rnd//0.}.csv
      """
}

// the docker file multifractal/virnet:5.1 only contains  dependencies for virnet