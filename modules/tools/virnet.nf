process virnet {
      errorStrategy 'ignore'
      label 'virnet'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
      file(dependencies) 
    output:
      tuple val(name), file("${name}_${random}.csv")
    script:
      """
      rnd=${Math.random()}
      cp -r ${dependencies}/* .
      python3 virnet/predict.py --input_dim=3000 --input=${fasta} --output=${name}_${random}.csv
      """
}

// the docker file multifractal/virnet:5.1 only contains  dependencies for virnet