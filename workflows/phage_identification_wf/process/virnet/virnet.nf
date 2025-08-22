process virnet {
    errorStrategy 'ignore'
    label 'virnet'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("${name}_*.csv")
    script:
        """
        python3  /virnet/predict.py --model_dir /virnet/data/saved_model --input_dim=3000 --input=${fasta} --output=${name}_\${PWD##*/}.csv 
        """
    stub:
        """
        echo ",ID,DESC,score,result" > ${name}_\${PWD##*/}.csv
        echo "0,"pos_phage_0,5e17de4f-ad9e-4fbd-a34d-32e2330ee0cc","pos_phage_0,5e17de4f-ad9e-4fbd-a34d-32e2330ee0cc",0.1751683,0" >> ${name}_\${PWD##*/}.csv
        """
}
