process input_suffix_check {
        label 'ubuntu'
    input:
        tuple val(name), file(file) 
    output:
        tuple val(name), file("${name}.fa")
    script:
        """
        case "${file}" in
            *.gz) 
                zcat ${file} > ${name}.fa
                ;;
            *.fna)
                cp ${file} ${name}.fa
                ;;
            *.fasta)
                cp ${file} ${name}.fa
                ;;
            *.fa)
                ;;
            *)
                echo "file format not supported...what the phage...(.fa .fasta .fna .gz is supported)"
                exit 1
        esac
        
        # replace spaces with _
        sed 's, ,_,g' -i ${name}.fa
        # replace , with _
        sed 's#,#_#g' -i ${name}.fa
        # replace . with _
        sed 's#\\.#_#g' -i ${name}.fa
        # replace | with _
        sed 's#|#_#g' -i ${name}.fa
        # replace / with _
        sed 's#/#_#g' -i ${name}.fa
        # remove empty lines
        sed '/^\$/d' -i ${name}.fa
        """
}