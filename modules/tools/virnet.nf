process virnet {
      //errorStrategy 'ignore'
      label 'virnet'
    input:
      tuple val(name), file(fasta) 
      file(dependencies) 
    output:
      tuple val(name), file("${name}_*.csv")
    script:
      """
      cp -r ${dependencies}/* .
      python3  /virnet/predict.py --model_path /virnet/data/saved_model/model_{}.h5 --input_dim=3000 --input=${fasta} --output=${name}_\${PWD##*/}.csv 
      """
}

//       

// the docker file multifractal/virnet:5.1 only contains  dependencies for virnet