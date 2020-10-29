process virnet {
    errorStrategy 'ignore'
    label 'virnet'
    input:
        tuple val(name), file(fasta) 
    output:
        tuple val(name), file("${name}_*.csv")
    script:
        """
        python3  /virnet/predict.py --model_dir /virnet/data/saved_model --input_dim=3000 --input=${fasta} --output=${name}_\${PWD##*/}.csv 
        """
}