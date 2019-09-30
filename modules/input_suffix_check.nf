process input_suffix_check {
        label 'ubuntu'
        echo true
    input:
        set val(name), file(file) 
    output:
        set val(name), file("${name}.fa")
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
        """
}